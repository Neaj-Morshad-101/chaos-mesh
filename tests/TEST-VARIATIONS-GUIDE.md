# Test Variations Index

This document provides a comprehensive guide to all test variations created for chaos engineering testing of KubeDB PostgreSQL HA Cluster.

## Overview

Each original test now has 5 variations (a, b, c, d, e) exploring different aspects:
- Different targets (primary, replica, all pods)
- Different intensities/durations
- Different modes (one, all, fixed-percent)
- Different parameters (latency, packet loss %, CPU load, etc.)

## Test 01: Pod Failure

| Variation | Focus | Duration | Mode | Target |
|-----------|-------|----------|------|--------|
| **01-pod-failure.yaml** | Original - Primary failure | 5m | one | primary |
| **01-pod-failure-a.yaml** | Short duration test | 1m | one | primary |
| **01-pod-failure-b.yaml** | Replica failure | 5m | one | secondary |
| **01-pod-failure-c.yaml** | All pods failure | 2m | all | all |
| **01-pod-failure-d.yaml** | Extended duration | 10m | one | primary |
| **01-pod-failure-e.yaml** | Fixed percentage (66%) | 3m | fixed-percent | all |

## Test 02: Pod Kill

| Variation | Focus | Grace Period | Mode | Target |
|-----------|-------|--------------|------|--------|
| **02-pod-kill.yaml** | Original - Primary kill | 0s | one | primary |
| **02-pod-kill-a.yaml** | Replica kill | 0s | one | secondary |
| **02-pod-kill-b.yaml** | All pods kill | 0s | all | all |
| **02-pod-kill-c.yaml** | Graceful shutdown (30s) | 30s | one | primary |
| **02-pod-kill-d.yaml** | Fixed percentage (66%) | 0s | fixed-percent | all |
| **02-pod-kill-e.yaml** | Coordinator container kill | 0s | one | primary (coordinator) |

## Test 03: Pod OOM

| Variation | Focus | Memory Size | Mode | Target |
|-----------|-------|-------------|------|--------|
| **03-pod-oom.yaml** | Original - Primary OOM | 1500MB | one | primary |
| **03-pod-oom-a.yaml** | Replica OOM | 1500MB | one | secondary |
| **03-pod-oom-b.yaml** | All pods light OOM | 800MB | all | all |
| **03-pod-oom-c.yaml** | Primary heavy OOM | 2000MB | one | primary |
| **03-pod-oom-d.yaml** | Fixed percentage (66%) | 1200MB | fixed-percent | all |
| **03-pod-oom-e.yaml** | Primary short duration | 1500MB | one | primary |

## Test 04: Kill PostgreSQL Process

| Variation | Focus | Container | Mode | Target |
|-----------|-------|-----------|------|--------|
| **04-kill-postgres-process.yaml** | Original - Primary process | postgres | one | primary |
| **04-kill-postgres-process-a.yaml** | Replica process kill | postgres | one | secondary |
| **04-kill-postgres-process-b.yaml** | Coordinator process kill | mssql-coordinator | one | primary |
| **04-kill-postgres-process-c.yaml** | All postgres processes | postgres | all | all |
| **04-kill-postgres-process-d.yaml** | Extended duration (2m) | postgres | one | primary |
| **04-kill-postgres-process-e.yaml** | Fixed percentage (66%) | postgres | fixed-percent | all |

## Test 05: Network Partition

| Variation | Focus | Direction | Duration | Scope |
|-----------|-------|-----------|----------|-------|
| **05-network-partition.yaml** | Original - Primary isolated | both | 5m | primary to secondary |
| **05-network-partition-a.yaml** | One direction only | to | 5m | primary to secondary |
| **05-network-partition-b.yaml** | Replica to primary | both | 3m | secondary to primary |
| **05-network-partition-c.yaml** | Short partition | both | 1m | primary to secondary |
| **05-network-partition-d.yaml** | All pods partitioned | both | 2m | all to all |
| **05-network-partition-e.yaml** | Extended partition | both | 10m | primary to secondary |

## Test 06: Network Bandwidth Limit

| Variation | Focus | Rate Limit | Mode | Target |
|-----------|-------|-----------|------|--------|
| **06-network-bandwidth.yaml** | Original - Primary 1mbps | 1mbps | one | primary |
| **06-network-bandwidth-a.yaml** | Replica bandwidth limit | 1mbps | one | secondary |
| **06-network-bandwidth-b.yaml** | All pods limit | 2mbps | all | all |
| **06-network-bandwidth-c.yaml** | One direction only | 1mbps | one | primary (to) |
| **06-network-bandwidth-d.yaml** | Higher rate (5mbps) | 5mbps | one | primary |
| **06-network-bandwidth-e.yaml** | Extreme limit (512kbps) | 512kbps | one | primary |

## Test 07: Network Delay

| Variation | Focus | Latency | Jitter | Mode |
|-----------|-------|---------|--------|------|
| **07-network-delay.yaml** | Original - 500ms delay | 500ms | 100ms | one |
| **07-network-delay-a.yaml** | Replica delay | 500ms | 100ms | one |
| **07-network-delay-b.yaml** | All pods light delay | 200ms | 50ms | all |
| **07-network-delay-c.yaml** | High latency (1000ms) | 1000ms | 200ms | one |
| **07-network-delay-d.yaml** | Low latency (100ms) | 100ms | 20ms | one |
| **07-network-delay-e.yaml** | One direction only | 500ms | 100ms | one (to) |

## Test 08: Network Packet Loss

| Variation | Focus | Loss % | Mode | Target |
|-----------|-------|--------|------|--------|
| **08-network-loss.yaml** | Original - 100% loss | 100% | one | primary |
| **08-network-loss-a.yaml** | Replica loss | 100% | one | secondary |
| **08-network-loss-b.yaml** | Partial loss (50%) | 50% | one | primary |
| **08-network-loss-c.yaml** | All pods light loss | 30% | all | all |
| **08-network-loss-d.yaml** | One direction 100% | 100% | one | primary (to) |
| **08-network-loss-e.yaml** | Light loss (10%) | 10% | one | primary |

## Test 09: Network Duplicate Packets

| Variation | Focus | Duplicate % | Mode | Target |
|-----------|-------|------------|------|--------|
| **09-network-duplicate.yaml** | Original - 50% duplicates | 50% | one | primary |
| **09-network-duplicate-a.yaml** | Light duplication (25%) | 25% | one | primary |
| **09-network-duplicate-b.yaml** | All pods duplication | 50% | all | all |
| **09-network-duplicate-c.yaml** | Replica duplication | 50% | one | secondary |
| **09-network-duplicate-d.yaml** | One direction only | 50% | one | primary (to) |
| **09-network-duplicate-e.yaml** | Heavy duplication (75%) | 75% | one | primary |

## Test 10: Network Packet Corruption

| Variation | Focus | Corruption % | Mode | Target |
|-----------|-------|-------------|------|--------|
| **10-network-corrupt.yaml** | Original - 50% corruption | 50% | one | primary |
| **10-network-corrupt-a.yaml** | Replica corruption | 50% | one | secondary |
| **10-network-corrupt-b.yaml** | All pods light corruption | 25% | all | all |
| **10-network-corrupt-c.yaml** | Light corruption (10%) | 10% | one | primary |
| **10-network-corrupt-d.yaml** | One direction only | 50% | one | primary (to) |
| **10-network-corrupt-e.yaml** | Heavy corruption (75%) | 75% | one | primary |

## Test 11: Time Offset

| Variation | Focus | Offset | Mode | Target |
|-----------|-------|--------|------|--------|
| **11-time-offset.yaml** | Original - 2h backward | -2h | one | primary |
| **11-time-offset-a.yaml** | Replica time offset | -2h | one | secondary |
| **11-time-offset-b.yaml** | Forward offset (2h) | +2h | one | primary |
| **11-time-offset-c.yaml** | All pods offset | -1h | all | all |
| **11-time-offset-d.yaml** | Small offset (30m) | -30m | one | primary |
| **11-time-offset-e.yaml** | Large offset (6h) | -6h | one | primary |

## Test 12: DNS Error

| Variation | Focus | Action | Mode | Duration |
|-----------|-------|--------|------|----------|
| **12-dns-error.yaml** | Original - DNS error | error | one | 10m |
| **12-dns-error-a.yaml** | Replica DNS error | error | one | 5m |
| **12-dns-error-b.yaml** | All pods DNS error | error | all | 3m |
| **12-dns-error-c.yaml** | DNS random response | random | one | 5m |
| **12-dns-error-d.yaml** | Short DNS error | error | one | 2m |
| **12-dns-error-e.yaml** | Long DNS error | error | one | 15m |

## Test 13: I/O Latency

| Variation | Focus | Delay | Percent | Mode |
|-----------|-------|-------|---------|------|
| **13-io-latency.yaml** | Original - 500ms latency | 500ms | 100% | one |
| **13-io-latency-a.yaml** | Replica I/O latency | 500ms | 100% | one |
| **13-io-latency-b.yaml** | All pods light latency | 200ms | 100% | all |
| **13-io-latency-c.yaml** | High latency (1000ms) | 1000ms | 100% | one |
| **13-io-latency-d.yaml** | Partial latency (50%) | 500ms | 50% | one |
| **13-io-latency-e.yaml** | Low latency (100ms) | 100ms | 100% | one |

## Test 14: I/O Fault

| Variation | Focus | Error Code | Percent | Mode |
|-----------|-------|-----------|---------|------|
| **14-io-fault.yaml** | Original - EIO (5) | 5 | 50% | one |
| **14-io-fault-a.yaml** | Replica I/O fault | 5 | 50% | one |
| **14-io-fault-b.yaml** | All pods light faults | 5 | 25% | all |
| **14-io-fault-c.yaml** | High fault rate (100%) | 5 | 100% | one |
| **14-io-fault-d.yaml** | Permission error (13) | 13 | 50% | one |
| **14-io-fault-e.yaml** | No space error (28) | 28 | 50% | one |

## Test 15: I/O Attribute Override

| Variation | Focus | Permissions | Percent | Mode |
|-----------|-------|-------------|---------|------|
| **15-io-attr-override.yaml** | Original - Read-only (444) | 444 | 100% | one |
| **15-io-attr-override-a.yaml** | Replica attr override | 444 | 100% | one |
| **15-io-attr-override-b.yaml** | All pods overrides | 555 | 100% | all |
| **15-io-attr-override-c.yaml** | Partial override (50%) | 444 | 50% | one |
| **15-io-attr-override-d.yaml** | Owner read-only (400) | 400 | 100% | one |
| **15-io-attr-override-e.yaml** | No permissions (000) | 000 | 100% | one |

## Test 16: I/O Mistake (Data Corruption)

| Variation | Focus | Filling | Max Occurrences | Max Length |
|-----------|-------|---------|-----------------|------------|
| **16-io-mistake.yaml** | Original - Random fill | random | 10 | 100 |
| **16-io-mistake-a.yaml** | Replica mistakes | random | 10 | 100 |
| **16-io-mistake-b.yaml** | All pods light mistakes | random | 5 | 50 |
| **16-io-mistake-c.yaml** | Heavy mistakes | random | 20 | 200 |
| **16-io-mistake-d.yaml** | Zero fill mistakes | zero | 10 | 100 |
| **16-io-mistake-e.yaml** | One bit fill mistakes | one | 10 | 100 |

## Test 17: Node Reboot (All Pods Kill)

| Variation | Focus | Mode | Scope | Duration |
|-----------|-------|------|-------|----------|
| **17-node-reboot.yaml** | Original - All pods kill | all | all | 30s |
| **17-node-reboot-a.yaml** | Short reboot test | all | all | 15s |
| **17-node-reboot-b.yaml** | Single pod kill | one | all | 30s |
| **17-node-reboot-c.yaml** | Primary reboot | one | primary | 30s |
| **17-node-reboot-d.yaml** | Replicas reboot | all | secondary | 30s |
| **17-node-reboot-e.yaml** | Fixed percentage (66%) | fixed-percent | all | 30s |

## Test 18: Stress CPU - Primary

| Variation | Focus | Workers | Load % | Duration |
|-----------|-------|---------|--------|----------|
| **18-stress-cpu-primary.yaml** | Original - 90% load | 2 | 90 | 10m |
| **18-stress-cpu-primary-a.yaml** | Replica CPU stress | 2 | 90 | 5m |
| **18-stress-cpu-primary-b.yaml** | All pods light CPU | 1 | 50 | 3m |
| **18-stress-cpu-primary-c.yaml** | Heavy CPU (100%) | 4 | 100 | 3m |
| **18-stress-cpu-primary-d.yaml** | Light CPU (30%) | 1 | 30 | 5m |
| **18-stress-cpu-primary-e.yaml** | Extended CPU stress | 2 | 90 | 15m |

## Test 19: Stress Memory - Replica

| Variation | Focus | Memory Size | Workers | Duration |
|-----------|-------|-------------|---------|----------|
| **19-stress-memory-replica.yaml** | Original - 800MB on replica | 800MB | 1 | 10m |
| **19-stress-memory-replica-a.yaml** | All pods light memory | 400MB | 1 | 5m |
| **19-stress-memory-replica-b.yaml** | Primary memory stress | 800MB | 1 | 5m |
| **19-stress-memory-replica-c.yaml** | Extreme memory (1200MB) | 1200MB | 2 | 3m |
| **19-stress-memory-replica-d.yaml** | Light memory (500MB) | 500MB | 1 | 5m |
| **19-stress-memory-replica-e.yaml** | Extended memory stress | 800MB | 1 | 15m |

## Testing Strategy

### Recommended Execution Order

1. **Start with light variations** (short duration, low intensity)
2. **Progress to standard variations** (original test parameters)
3. **Move to extreme variations** (high intensity, longer duration)
4. **Test replica and all-pods variations** to understand cluster behavior

### What Each Variation Tests

- **Primary vs Replica**: Tests if the system handles failures equally
- **Single vs All**: Tests partial vs complete cluster failures
- **Duration variations**: Tests recovery time and sustained chaos impact
- **Intensity variations**: Tests threshold beyond which system fails
- **Mode variations**: Tests different selection strategies

## Expected Outcomes

With only 6 tests passing on your client, these variations should help identify:

1. **Which specific scenarios fail** - narrow down problem areas
2. **Whether it's target-specific** - primary vs replica handling
3. **Whether it's intensity-dependent** - light vs heavy chaos
4. **Whether it's duration-dependent** - short vs long running chaos
5. **Configuration differences** - compare working vs failing scenarios

## Running All Variations

To run a complete test suite:

```bash
#!/bin/bash
# Run all test variations
for test in /tests/*-{a,b,c,d,e}.yaml; do
  if [ -f "$test" ]; then
    echo "Running: $(basename $test)"
    kubectl apply -f "$test"
    sleep 600  # 10 minutes per test
    kubectl delete -f "$test"
    sleep 60   # 1 minute between tests
  fi
done
```

## Notes

- Each variation is independent and can be run in isolation
- Original tests are preserved and unchanged
- Variations use consistent naming: `XX-test-name-Y.yaml` (Y = a,b,c,d,e)
- All tests target the `demo` namespace and `sqlserver-ag-cluster` instance
- Adjust durations based on your monitoring and analysis capabilities
