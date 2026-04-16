# Test Analysis: Passing vs Failing

## Current Status: 6/19 Tests Passing

### ✅ Passing Tests

| # | Test | Type | Reason for Pass |
|---|------|------|-----------------|
| 02 | Pod Kill | Pod Disruption | Clean termination, quick failover |
| 08 | Network Loss | Network Chaos | TCP handles packet loss gracefully |
| 09 | Network Duplicate | Network Chaos | TCP handles duplicates via sequence numbers |
| 12 | DNS Error | System | DNS caching provides resilience |
| 18 | CPU Stress | Resource | OS throttles, no hard failure |
| 19 | Memory Stress | Resource | Container handles pressure without OOM |

### ❌ Failing Tests (13 tests)

| # | Test | Type | Likely Issue | Variations to Try |
|---|------|------|--------------|------------------|
| 01 | Pod Failure | Pod Disruption | Extended unavailability → HA failover fails | -a (replica), -b (all), -d (longer), -e (fixed%) |
| 03 | Pod OOM | Pod Disruption | Memory exhaustion → pod kills uncleanly | -a (replica), -b (all), -c (heavy), -d (fixed%) |
| 04 | Kill Process | Pod Disruption | Process death → not restarted properly | -a (replica), -b (all), -c (all procs), -d (longer) |
| 05 | Network Partition | Network Chaos | Split-brain → quorum issues | -a (one-way), -b (replica), -c (short), -d (all), -e (long) |
| 06 | Bandwidth Limit | Network Chaos | Replication lag → inconsistency | -a (replica), -b (all), -c (one-way), -d (higher), -e (extreme) |
| 07 | Network Delay | Network Chaos | Timeout cascades → connection failures | -a (replica), -b (all), -c (high latency), -d (low), -e (one-way) |
| 10 | Network Corrupt | Network Chaos | Data integrity → protocol errors | -a (replica), -b (all), -c (light), -d (one-way), -e (heavy) |
| 11 | Time Offset | System | Clock skew → timestamp issues | -a (replica), -b (all), -c (all), -d (small), -e (large) |
| 13 | I/O Latency | Storage | Storage slowness → timeout/deadlock | -a (replica), -b (all), -c (high), -d (partial), -e (low) |
| 14 | I/O Fault | Storage | Storage errors → query failures | -a (replica), -b (all), -c (high%), -d (EPERM), -e (ENOSPC) |
| 15 | I/O Attr Override | Storage | Read-only files → write failures | -a (replica), -b (all), -c (partial), -d (400 perm), -e (000 perm) |
| 16 | I/O Mistake | Storage | Data corruption → integrity failures | -a (replica), -b (all), -c (high%), -d (zero-fill), -e (one-fill) |
| 17 | Node Reboot | Pod Disruption | All pods down → complete failure | -a (short), -b (single), -c (primary), -d (replicas), -e (fixed%) |

## Investigation Roadmap

### Phase 1: Understand Passing Tests (✅ 6 tests)

Start by testing variations of the 6 passing tests to understand what works:

```bash
echo "=== Phase 1: Understand Passing Tests ==="

# 02-pod-kill - why does this work?
for var in a b c d e; do
  echo "Testing 02-pod-kill-$var.yaml"
  kubectl apply -f tests/02-pod-kill-$var.yaml
  sleep 300
  kubectl delete -f tests/02-pod-kill-$var.yaml
  sleep 60
done

# 08-network-loss - why does this work?
for var in a b c d e; do
  echo "Testing 08-network-loss-$var.yaml"
  kubectl apply -f tests/08-network-loss-$var.yaml
  sleep 300
  kubectl delete -f tests/08-network-loss-$var.yaml
  sleep 60
done

# ... repeat for 09, 12, 18, 19
```

**Goal**: Identify common traits of passing tests

### Phase 2: Replica vs Primary (Find Target-Specific Issues)

Test if failures are specific to primary or replica:

```bash
echo "=== Phase 2: Replica vs Primary Tests ==="

# Compare primary vs replica for FAILING tests
FAILING=(01 03 04 05 06 07 10 11 13 14 15 16 17)

for test in "${FAILING[@]}"; do
  echo "Testing $test with replica variant (-a)"
  kubectl apply -f tests/$test-*-a.yaml
  sleep 300
  kubectl delete -f tests/$test-*-a.yaml
  sleep 60
done
```

**Goal**: Identify if failures are primary-specific or affect entire cluster

### Phase 3: Intensity & Duration (Find Thresholds)

Test if failures are threshold-dependent:

```bash
echo "=== Phase 3: Find Failure Thresholds ==="

# For each failing test, try light → heavy variations
# Pattern: usually c=light, a/d=medium, e=heavy

for test in 06 07 10 13 14 15 16; do
  for var in c a d e; do
    echo "Testing $test-...-$var.yaml (intensity: $var)"
    kubectl apply -f tests/$test-*-$var.yaml
    sleep 300
    kubectl delete -f tests/$test-*-$var.yaml
    sleep 60
  done
done
```

**Goal**: Find intensity threshold where failures start

### Phase 4: All Pods Impact (Find Cluster-Level Issues)

Test complete cluster disruption:

```bash
echo "=== Phase 4: All Pods Impact ==="

# Test with all pods affected (-b variants)
FAILING=(01 03 04 05 06 07 10 11 13 14 15 16 17)

for test in "${FAILING[@]}"; do
  echo "Testing $test with all pods variant (-b)"
  kubectl apply -f tests/$test-*-b.yaml
  sleep 300
  kubectl delete -f tests/$test-*-b.yaml
  sleep 60
done
```

**Goal**: Understand cluster behavior under complete failure

### Phase 5: Duration (Find Time-Dependent Issues)

Test sustained chaos:

```bash
echo "=== Phase 5: Time-Dependent Issues ==="

# Compare short vs long duration
# Pattern: -a/-c = short/light, d = extended, e = extreme

for test in 01 05 06 07 11 13 14 15 16; do
  for var in c d e; do
    echo "Testing $test with duration variant (-$var)"
    kubectl apply -f tests/$test-*-$var.yaml
    sleep 600  # Longer wait for extended tests
    kubectl delete -f tests/$test-*-$var.yaml
    sleep 60
  done
done
```

**Goal**: Identify if failures occur over time or immediately

## Decision Tree for Analysis

```
Start
  ├─ Does variation -a (replica) fail?
  │  ├─ YES → Replica-specific issue
  │  └─ NO → Might need all-pods or higher intensity
  │
  ├─ Does variation -b (all pods) fail?
  │  ├─ YES → Cluster-wide issue, leader election broken
  │  └─ NO → Might need higher intensity
  │
  ├─ Does variation -e (heavy/extreme) fail?
  │  ├─ YES → Threshold-dependent, system breaks at high load
  │  └─ NO → Light chaos tolerance is good
  │
  └─ Does variation -d (extended) fail?
     ├─ YES → Time-dependent issue, recovery is slow
     └─ NO → System recovers from quick chaos
```

## Comparison Matrix Template

Create a table to track results:

```markdown
| Test | Pass | a-Replica | b-All | c-Light | d-Extended | e-Heavy |
|------|------|-----------|-------|---------|-----------|---------|
| 01   | ❌   | ?         | ?     | ?       | ?         | ?       |
| 02   | ✅   | ?         | ?     | ?       | ?         | ?       |
| 03   | ❌   | ?         | ?     | ?       | ?         | ?       |
| ... | ... | ... | ... | ... | ... | ... |
```

## Common Failure Patterns

### Pattern A: "Original fails, all variations fail"
**Diagnosis**: Feature/config issue
- Problem is fundamental to that test type
- Not specific to intensity, duration, or target
- **Action**: Review cluster setup, check logs

### Pattern B: "Original fails, replica passes"
**Diagnosis**: Primary-specific vulnerability
- System handles replica failures but not primary
- Failover mechanism may be broken
- **Action**: Test failover process, check primary handling

### Pattern C: "Original fails, light variation passes"
**Diagnosis**: Threshold-dependent failure
- System can handle small chaos but not larger
- Might be resource exhaustion or timeout
- **Action**: Adjust resource limits, tune timeout values

### Pattern D: "Original fails, quick variation passes"
**Diagnosis**: Time-dependent failure
- System fails after sustained chaos
- Might be memory leak, connection exhaustion
- **Action**: Monitor resource usage during tests

### Pattern E: "Original fails, all-pods passes"
**Diagnosis**: Quorum/split-brain issues
- Single-pod failure triggers issues but all-pods triggers failover
- **Action**: Check quorum settings, leader election

## Expected Insights from Each Test

### For Passing Tests (Use as Reference)
- Understand **why** they pass
- Look for design patterns that work
- Identify differences from failing tests
- Can they be applied to failing tests?

### For Replica Variants (-a)
- **Replica failures are easier than primary**?
  - System design accounts for replica loss ✓
- **Replica failures are harder than primary**?
  - Replica handling is weaker - FIX IT
- **Same difficulty**?
  - Both are problematic

### For All-Pods Variants (-b)
- **All-pods succeeds when original fails**?
  - Single pod failure causes issues but coordinated failure doesn't
  - Check: leader election, quorum, split-brain handling
- **All-pods fails when original fails**?
  - System cannot recover from any failure
  - Check: recovery mechanism, bootstrap

### For Extended Variants (-d, -e)
- **Fails after time Xm**?
  - Identify what fails first (connection, memory, data)
  - Look for leaks, slow degradation
- **Fails immediately but original passes**?
  - Higher intensity exposes resource limits
  - Check: resource allocation, connection pooling

## Recommendations for Testing

1. **Start with variation -a (replica)** - Usually passes for many tests
2. **Then test -c (light)** - See if intensity matters
3. **Then test -b (all)** - See if quorum/coordination matters
4. **Then test -d/-e (extended/heavy)** - See if threshold or time matters
5. **Document findings** - Build the comparison matrix above

This systematic approach will help identify the exact cause of each failure.

---

**Key Insight**: The 6 passing tests likely share common characteristics:
- They trigger automatic/built-in handling
- They don't rely on external decision-making
- They work with TCP/protocol-level recovery
- They don't cause data inconsistency

The 13 failing tests likely:
- Require application-level recovery
- Depend on HA coordination
- Can cause split-brain or quorum issues
- Have timeout or resource constraints

Your variations should reveal which of these is the actual problem.
