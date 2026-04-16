# Quick Test Variations Reference Card

## 📊 Statistics
- **Total Tests**: 114 (19 original + 95 variations)
- **Tests per Category**: 6 each
- **Variation Types**: a, b, c, d, e (5 per original test)

## 🎯 Variation Meanings

| Letter | Typical Focus | Purpose |
|--------|--------------|---------|
| **a** | Replica/Secondary | Test secondary pod behavior |
| **b** | All Pods | Test complete cluster failure |
| **c** | Light/Alternative | Test lower intensity scenarios |
| **d** | Extended/Alternative Mode | Test sustained or different approach |
| **e** | Heavy/Edge Case | Test extreme scenarios |

## 📋 Test Categories

### Pod Tests (Tests 01-04)
- 01: Pod Failure - pods become unavailable
- 02: Pod Kill - immediate pod termination
- 03: Pod OOM - memory pressure
- 04: Kill Process - container process death

**Run when:** Testing pod-level resilience

### Network Tests (Tests 05-10)
- 05: Network Partition - isolated nodes
- 06: Bandwidth Limit - throughput constraint
- 07: Network Delay - latency injection
- 08: Packet Loss - missing packets
- 09: Packet Duplicate - repeated packets
- 10: Packet Corruption - damaged data

**Run when:** Testing network resilience

### System Tests (Tests 11-12)
- 11: Time Offset - clock skew
- 12: DNS Error - name resolution failure

**Run when:** Testing system-level issues

### I/O Tests (Tests 13-16)
- 13: I/O Latency - storage slowness
- 14: I/O Fault - storage errors
- 15: I/O Attr Override - permission issues
- 16: I/O Mistake - data corruption

**Run when:** Testing storage resilience

### Resource Tests (Tests 17-19)
- 17: Node Reboot - complete pod kill
- 18: CPU Stress - processor load
- 19: Memory Stress - memory pressure

**Run when:** Testing resource constraints

## ✅ Currently Passing Tests

```bash
# These 6 tests pass on your client:
kubectl apply -f tests/02-pod-kill.yaml
kubectl apply -f tests/08-network-loss.yaml
kubectl apply -f tests/09-network-duplicate.yaml
kubectl apply -f tests/12-dns-error.yaml
kubectl apply -f tests/18-stress-cpu-primary.yaml
kubectl apply -f tests/19-stress-memory-replica.yaml
```

## 🔍 Investigation Strategy

### Step 1: Test Passing Tests' Variations
```bash
# Test pod-kill with all targets
kubectl apply -f tests/02-pod-kill-a.yaml  # replica
kubectl apply -f tests/02-pod-kill-b.yaml  # all pods
kubectl apply -f tests/02-pod-kill-c.yaml  # graceful
kubectl apply -f tests/02-pod-kill-d.yaml  # fixed-percent
kubectl apply -f tests/02-pod-kill-e.yaml  # coordinator
```

### Step 2: Test Failing Tests' Light Variations
```bash
# Start with light versions of failing tests
kubectl apply -f tests/01-pod-failure-a.yaml   # replica
kubectl apply -f tests/03-pod-oom-a.yaml       # replica
kubectl apply -f tests/05-network-partition-c.yaml  # short
# ... etc
```

### Step 3: Run All Variations of One Failing Test
```bash
# Deep dive into a single failing test
for variant in a b c d e; do
  echo "Testing 01-pod-failure-$variant.yaml"
  kubectl apply -f tests/01-pod-failure-$variant.yaml
  sleep 10m
  kubectl delete -f tests/01-pod-failure-$variant.yaml
done
```

## 📝 Monitoring During Tests

Watch these metrics:
```bash
# Pod status
kubectl get pods -n demo -w

# Pod events
kubectl describe pod <pod-name> -n demo

# Database connectivity
kubectl exec -it sqlserver-ag-cluster-0 -n demo -- psql -U postgres -c "SELECT NOW();"

# Replication status
kubectl exec -it sqlserver-ag-cluster-0 -n demo -- psql -U postgres -c "SELECT * FROM mssql_stat_replication;"

# Cluster status
kubectl get mssql -n demo
```

## 🚀 Running Single Test

```bash
# Apply
kubectl apply -f tests/XX-test-name-Y.yaml

# Monitor
watch kubectl get pods -n demo -o wide

# Check details
kubectl describe podchaos mssql-primary-pod-failure -n chaos-mesh

# Clean up
kubectl delete -f tests/XX-test-name-Y.yaml
```

## 🔄 Running Sequential Tests

```bash
#!/bin/bash
TESTS=(
  "02-pod-kill-a.yaml"
  "02-pod-kill-b.yaml"
  "02-pod-kill-c.yaml"
  "02-pod-kill-d.yaml"
  "02-pod-kill-e.yaml"
)

for test in "${TESTS[@]}"; do
  echo "Running: $test"
  kubectl apply -f tests/$test
  sleep 600  # 10 minutes
  kubectl delete -f tests/$test
  sleep 60   # 1 minute between tests
done
```

## 📊 Result Documentation Template

```markdown
## Test: XX-test-name-Y.yaml
- **Date**: YYYY-MM-DD
- **Duration**: Xm
- **Status**: PASS / FAIL
- **Pod Status**: (describe what happened to pods)
- **Database Impact**: (describe any query failures)
- **Recovery Time**: (how long to get back to normal)
- **Notes**: (any unusual behavior)
```

## 🎓 Expected Behavior Patterns

### Passing Tests Often Show:
- Quick failover (< 30s)
- Automatic leader election
- Replicas stay in sync
- No data loss
- System recovers after chaos stops

### Failing Tests Often Show:
- Long unavailability (> 5m)
- Split-brain scenarios
- Replication lag
- Connection timeouts
- Slow recovery

## 📌 Key Test Parameters

### Duration
- **Short**: 1-2m (quick impact test)
- **Normal**: 3-5m (standard chaos)
- **Extended**: 10-15m (sustained chaos)

### Intensity
- **Light**: 10-30% (minor impact)
- **Normal**: 50-75% (moderate impact)
- **Heavy**: 100% (maximum impact)

### Target
- **one**: Single pod (least disruptive)
- **all**: All matching pods (most disruptive)
- **fixed-percent**: X% of pods

## 🔗 Related Documentation

- `TEST-VARIATIONS-GUIDE.md` - Detailed reference for each variation
- `VARIATIONS-SUMMARY.md` - Comprehensive overview
- `README.md` - Original test descriptions
- `QUICK-REFERENCE.md` - Existing quick reference

## 💡 Tips for Success

1. **Start small**: Run short-duration, low-intensity tests first
2. **Monitor closely**: Watch pods, logs, and database during tests
3. **Allow recovery**: Give cluster time to recover between tests
4. **Document results**: Track which tests pass and which fail
5. **Compare scenarios**: Look for patterns in failures
6. **Test systematically**: Run all variations of one test type together

## ⚠️ Caution

- Some tests may cause data inconsistency if not handled properly
- Always have monitoring/alerting in place
- Ensure cluster can recover automatically
- Back up important data before extensive testing
- Run during maintenance windows if possible

---

**Created**: January 2025  
**Target**: KubeDB PostgreSQL 16.4-bookworm HA Cluster  
**Purpose**: Comprehensive chaos engineering test suite
