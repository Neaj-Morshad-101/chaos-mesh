# Test Variations Checklist

## 🧪 Complete Test Inventory

### Test 01: Pod Failure
- [ ] `01-pod-failure.yaml` (original - 5m, primary)
- [ ] `01-pod-failure-a.yaml` (1m, primary - short duration)
- [ ] `01-pod-failure-b.yaml` (5m, secondary - replica)
- [ ] `01-pod-failure-c.yaml` (2m, all pods)
- [ ] `01-pod-failure-d.yaml` (10m, primary - extended)
- [ ] `01-pod-failure-e.yaml` (3m, fixed-percent 66%)

### Test 02: Pod Kill ✅
- [ ] `02-pod-kill.yaml` (original - primary)
- [ ] `02-pod-kill-a.yaml` (secondary - replica)
- [ ] `02-pod-kill-b.yaml` (all pods)
- [ ] `02-pod-kill-c.yaml` (graceful, 30s grace period)
- [ ] `02-pod-kill-d.yaml` (fixed-percent 66%)
- [ ] `02-pod-kill-e.yaml` (coordinator container)

### Test 03: Pod OOM
- [ ] `03-pod-oom.yaml` (original - 1500MB, primary)
- [ ] `03-pod-oom-a.yaml` (1500MB, secondary - replica)
- [ ] `03-pod-oom-b.yaml` (800MB, all pods - light)
- [ ] `03-pod-oom-c.yaml` (2000MB, primary - heavy)
- [ ] `03-pod-oom-d.yaml` (1200MB, fixed-percent 66%)
- [ ] `03-pod-oom-e.yaml` (1500MB, 2m duration, primary)

### Test 04: Kill PostgreSQL Process
- [ ] `04-kill-postgres-process.yaml` (original - primary)
- [ ] `04-kill-postgres-process-a.yaml` (secondary - replica)
- [ ] `04-kill-postgres-process-b.yaml` (coordinator - primary)
- [ ] `04-kill-postgres-process-c.yaml` (all postgres containers)
- [ ] `04-kill-postgres-process-d.yaml` (2m extended, primary)
- [ ] `04-kill-postgres-process-e.yaml` (fixed-percent 66%)

### Test 05: Network Partition
- [ ] `05-network-partition.yaml` (original - both directions)
- [ ] `05-network-partition-a.yaml` (to direction only)
- [ ] `05-network-partition-b.yaml` (secondary to primary, 3m)
- [ ] `05-network-partition-c.yaml` (both, 1m - short)
- [ ] `05-network-partition-d.yaml` (all pods partitioned)
- [ ] `05-network-partition-e.yaml` (10m extended)

### Test 06: Network Bandwidth Limit
- [ ] `06-network-bandwidth.yaml` (original - 1mbps, primary)
- [ ] `06-network-bandwidth-a.yaml` (1mbps, secondary - replica)
- [ ] `06-network-bandwidth-b.yaml` (2mbps, all pods)
- [ ] `06-network-bandwidth-c.yaml` (1mbps, to direction)
- [ ] `06-network-bandwidth-d.yaml` (5mbps higher rate)
- [ ] `06-network-bandwidth-e.yaml` (512kbps extreme)

### Test 07: Network Delay
- [ ] `07-network-delay.yaml` (original - 500ms, primary)
- [ ] `07-network-delay-a.yaml` (500ms, secondary - replica)
- [ ] `07-network-delay-b.yaml` (200ms light, all pods)
- [ ] `07-network-delay-c.yaml` (1000ms high latency)
- [ ] `07-network-delay-d.yaml` (100ms low latency)
- [ ] `07-network-delay-e.yaml` (500ms, to direction)

### Test 08: Network Packet Loss ✅
- [ ] `08-network-loss.yaml` (original - 100%, primary)
- [ ] `08-network-loss-a.yaml` (100%, secondary - replica)
- [ ] `08-network-loss-b.yaml` (50% partial, primary)
- [ ] `08-network-loss-c.yaml` (30% light, all pods)
- [ ] `08-network-loss-d.yaml` (100%, to direction)
- [ ] `08-network-loss-e.yaml` (10% light)

### Test 09: Network Duplicate Packets ✅
- [ ] `09-network-duplicate.yaml` (original - 50%, primary)
- [ ] `09-network-duplicate-a.yaml` (25% light)
- [ ] `09-network-duplicate-b.yaml` (50%, all pods)
- [ ] `09-network-duplicate-c.yaml` (50%, secondary - replica)
- [ ] `09-network-duplicate-d.yaml` (50%, to direction)
- [ ] `09-network-duplicate-e.yaml` (75% heavy)

### Test 10: Network Packet Corruption
- [ ] `10-network-corrupt.yaml` (original - 50%, primary)
- [ ] `10-network-corrupt-a.yaml` (50%, secondary - replica)
- [ ] `10-network-corrupt-b.yaml` (25% light, all pods)
- [ ] `10-network-corrupt-c.yaml` (10% light)
- [ ] `10-network-corrupt-d.yaml` (50%, to direction)
- [ ] `10-network-corrupt-e.yaml` (75% heavy)

### Test 11: Time Offset
- [ ] `11-time-offset.yaml` (original - -2h, primary)
- [ ] `11-time-offset-a.yaml` (-2h, secondary - replica)
- [ ] `11-time-offset-b.yaml` (+2h forward, primary)
- [ ] `11-time-offset-c.yaml` (-1h, all pods)
- [ ] `11-time-offset-d.yaml` (-30m small offset)
- [ ] `11-time-offset-e.yaml` (-6h large offset)

### Test 12: DNS Error ✅
- [ ] `12-dns-error.yaml` (original - error action, primary)
- [ ] `12-dns-error-a.yaml` (error, secondary - replica)
- [ ] `12-dns-error-b.yaml` (error, all pods)
- [ ] `12-dns-error-c.yaml` (random response)
- [ ] `12-dns-error-d.yaml` (error, 2m short)
- [ ] `12-dns-error-e.yaml` (error, 15m long)

### Test 13: I/O Latency
- [ ] `13-io-latency.yaml` (original - 500ms, 100%, primary)
- [ ] `13-io-latency-a.yaml` (500ms, 100%, secondary - replica)
- [ ] `13-io-latency-b.yaml` (200ms light, 100%, all pods)
- [ ] `13-io-latency-c.yaml` (1000ms high, 100%)
- [ ] `13-io-latency-d.yaml` (500ms, 50% partial)
- [ ] `13-io-latency-e.yaml` (100ms low)

### Test 14: I/O Fault
- [ ] `14-io-fault.yaml` (original - EIO, 50%, primary)
- [ ] `14-io-fault-a.yaml` (EIO, 50%, secondary - replica)
- [ ] `14-io-fault-b.yaml` (EIO, 25% light, all pods)
- [ ] `14-io-fault-c.yaml` (EIO, 100% high rate)
- [ ] `14-io-fault-d.yaml` (EPERM err 13, 50%)
- [ ] `14-io-fault-e.yaml` (ENOSPC err 28, 50%)

### Test 15: I/O Attribute Override
- [ ] `15-io-attr-override.yaml` (original - 444, 100%, primary)
- [ ] `15-io-attr-override-a.yaml` (444, 100%, secondary - replica)
- [ ] `15-io-attr-override-b.yaml` (555, 100%, all pods)
- [ ] `15-io-attr-override-c.yaml` (444, 50% partial)
- [ ] `15-io-attr-override-d.yaml` (400 owner read-only)
- [ ] `15-io-attr-override-e.yaml` (000 no permissions)

### Test 16: I/O Mistake (Data Corruption)
- [ ] `16-io-mistake.yaml` (original - random fill, primary)
- [ ] `16-io-mistake-a.yaml` (random fill, secondary - replica)
- [ ] `16-io-mistake-b.yaml` (random fill, light, all pods)
- [ ] `16-io-mistake-c.yaml` (random fill, heavy)
- [ ] `16-io-mistake-d.yaml` (zero fill)
- [ ] `16-io-mistake-e.yaml` (one bit fill)

### Test 17: Node Reboot
- [ ] `17-node-reboot.yaml` (original - all pods, 30s)
- [ ] `17-node-reboot-a.yaml` (all pods, 15s short)
- [ ] `17-node-reboot-b.yaml` (one pod, 30s)
- [ ] `17-node-reboot-c.yaml` (primary pod, 30s)
- [ ] `17-node-reboot-d.yaml` (all replicas, 30s)
- [ ] `17-node-reboot-e.yaml` (fixed-percent 66%, 30s)

### Test 18: Stress CPU - Primary ✅
- [ ] `18-stress-cpu-primary.yaml` (original - 90% load, 2 workers)
- [ ] `18-stress-cpu-primary-a.yaml` (90% load, 2 workers, secondary - replica)
- [ ] `18-stress-cpu-primary-b.yaml` (50% light, 1 worker, all pods)
- [ ] `18-stress-cpu-primary-c.yaml` (100% heavy, 4 workers)
- [ ] `18-stress-cpu-primary-d.yaml` (30% light, 1 worker)
- [ ] `18-stress-cpu-primary-e.yaml` (90% load, 15m extended)

### Test 19: Stress Memory - Replica ✅
- [ ] `19-stress-memory-replica.yaml` (original - 800MB, secondary)
- [ ] `19-stress-memory-replica-a.yaml` (400MB light, all pods)
- [ ] `19-stress-memory-replica-b.yaml` (800MB, primary)
- [ ] `19-stress-memory-replica-c.yaml` (1200MB extreme, 2 workers)
- [ ] `19-stress-memory-replica-d.yaml` (500MB light)
- [ ] `19-stress-memory-replica-e.yaml` (800MB, 15m extended)

## Summary Stats

- **Total Tests**: 114 (19 original + 95 variations)
- **Passing Tests**: 6 (02, 08, 09, 12, 18, 19)
- **Failing Tests**: 13 (01, 03, 04, 05, 06, 07, 10, 11, 13, 14, 15, 16, 17)

## Testing Phases

### Phase 1: Validate Passing Tests
Run all variations of the 6 passing tests to understand why they work.
- [ ] Complete Test 02 variants (6 tests)
- [ ] Complete Test 08 variants (6 tests)
- [ ] Complete Test 09 variants (6 tests)
- [ ] Complete Test 12 variants (6 tests)
- [ ] Complete Test 18 variants (6 tests)
- [ ] Complete Test 19 variants (6 tests)

**Total**: 36 tests to run

### Phase 2: Analyze Replica Impact
Test -a variants of all failing tests to see if replicas are the issue.
- [ ] Test 01-a, 03-a, 04-a, 05-a, 06-a, 07-a, 10-a, 11-a, 13-a, 14-a, 15-a, 16-a, 17-a

**Total**: 13 tests to run

### Phase 3: Find Thresholds
Test light/heavy variants (-c, -e) of failing tests.
- [ ] Complete light variants (-c) for all 13 failing tests
- [ ] Complete heavy variants (-e) for all 13 failing tests

**Total**: 26 tests to run

### Phase 4: Full Matrix
Complete all remaining variants.
- [ ] All -b variants (all pods)
- [ ] All -d variants (extended/alternative)

**Total**: 26 tests to run

## Execution Guide

### Quick Start (Test Today)
Run passing test variations first - should all pass:
```bash
for test in 02-pod-kill-{a..e}.yaml; do
  echo "Running $test"
  kubectl apply -f tests/$test
  sleep 300
  kubectl delete -f tests/$test
  sleep 60
done
```

### Full Investigation (This Week)
Run all 114 tests systematically:
1. Phase 1: 36 tests (passing variants)
2. Phase 2: 13 tests (replica variants of failing)
3. Phase 3: 26 tests (light/heavy variants)
4. Phase 4: 26 tests (all/extended variants)
5. Remaining: 13 original failing tests

**Total Time**: ~57 hours (at 30 min per test + 5 min buffer)

## Documentation Files Created

1. **TEST-VARIATIONS-GUIDE.md** - Detailed reference for each variation
2. **VARIATIONS-SUMMARY.md** - Overview and expected usage patterns
3. **QUICK-REFERENCE-VARIATIONS.md** - Quick lookup and monitoring tips
4. **ANALYSIS-FRAMEWORK.md** - Systematic investigation approach
5. **This file** - Complete checklist of all tests

## Notes

- ✅ = Test category is passing
- ❌ = Test category is failing
- All tests preserve original namespace (`demo`) and cluster name (`sqlserver-ag-cluster`)
- No existing tests were modified
- All variations use consistent naming convention
