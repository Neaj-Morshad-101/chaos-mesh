# Test Variations Summary

## What Was Created

You now have **95 new test variations** in addition to your **19 original tests**, for a total of **114 chaos engineering tests**.

### Breakdown by Category

| Test Category | Original | Variations | Total | Focus Area |
|---------------|----------|-----------|-------|------------|
| Pod Failure | 1 | 5 | 6 | Pod unavailability scenarios |
| Pod Kill | 1 | 5 | 6 | Immediate pod termination |
| Pod OOM | 1 | 5 | 6 | Memory pressure and limits |
| Kill Process | 1 | 5 | 6 | Container process failures |
| Network Partition | 1 | 5 | 6 | Network isolation |
| Network Bandwidth | 1 | 5 | 6 | Throughput constraints |
| Network Delay | 1 | 5 | 6 | Latency injection |
| Network Loss | 1 | 5 | 6 | Packet loss scenarios |
| Network Duplicate | 1 | 5 | 6 | Duplicate packet handling |
| Network Corrupt | 1 | 5 | 6 | Data corruption in transit |
| Time Offset | 1 | 5 | 6 | Clock skew scenarios |
| DNS Error | 1 | 5 | 6 | DNS resolution failures |
| I/O Latency | 1 | 5 | 6 | Storage latency |
| I/O Fault | 1 | 5 | 6 | I/O error injection |
| I/O Attr Override | 1 | 5 | 6 | File permission changes |
| I/O Mistake | 1 | 5 | 6 | Data corruption on disk |
| Node Reboot | 1 | 5 | 6 | Full node failure |
| CPU Stress | 1 | 5 | 6 | CPU resource constraints |
| Memory Stress | 1 | 5 | 6 | Memory resource constraints |
| **TOTAL** | **19** | **95** | **114** | |

## Variation Strategy

Each test has 5 variations designed to explore different dimensions:

### **Variation A**: Replica/Secondary Target
- Tests impact on secondary/replica pods
- Checks if failover mechanism works when secondary is affected
- Verifies primary can continue with degraded replicas

### **Variation B**: All Pods Impact
- Tests simultaneous failure of multiple/all pods
- Most extreme scenario for cluster-wide issues
- Identifies complete cluster failure behavior

### **Variation C**: Alternative Intensity or Direction
- Varies key parameters (latency, loss %, load, etc.)
- Tests lighter or more specific scenarios
- Helps identify threshold values

### **Variation D**: Extended Duration or Alternative Approach
- Tests sustained chaos over longer periods
- Tests different modes (fixed-percent vs one vs all)
- Identifies time-dependent failures

### **Variation E**: Maximum Intensity or Edge Case
- Tests extreme parameter values
- Tests longest durations
- Tests permission/access edge cases

## Key Variation Patterns

### Pod-Level Tests (01-04)
Each has variations for:
- Primary pod disruption
- Replica pod disruption  
- All pods disruption
- Extended duration
- Fixed percentage selection

### Network Tests (05-10)
Each has variations for:
- Primary node affected
- Replica node affected
- All nodes affected
- Different durations (short/long)
- Different intensities (light/medium/heavy)

### Time & DNS Tests (11-12)
Each has variations for:
- Primary pod affected
- Replica pod affected
- All pods affected
- Different durations
- Different parameter values

### I/O Tests (13-16)
Each has variations for:
- Primary pod affected
- Replica pod affected
- All pods affected
- Different percentages
- Different parameters (permissions, error codes, etc.)

### Resource Tests (17-19)
Each has variations for:
- All pods
- Single pod
- Primary pod
- Replica pod
- Different intensity levels

## Expected Usage Pattern

### Phase 1: Identify Working Tests
Run your 6 passing tests to establish baseline:
- ✓ 02-pod-kill.yaml
- ✓ 08-network-loss.yaml
- ✓ 09-network-duplicate.yaml
- ✓ 12-dns-error.yaml
- ✓ 18-stress-cpu-primary.yaml
- ✓ 19-stress-memory-replica.yaml

### Phase 2: Run Variations of Passing Tests
Test variations of the 6 passing tests to understand:
- Do they pass with different targets? (primary vs replica)
- Do they pass with all pods? 
- Do they pass with extended duration?
- Do they pass with different intensity?

### Phase 3: Systematic Failure Analysis
For the 13 failing tests, test variations to narrow down:
- **Is it target-specific?** - Test replica/all variations
- **Is it intensity-dependent?** - Test high/low variations
- **Is it duration-dependent?** - Test short/long variations
- **Is it mode-dependent?** - Test one/all/fixed-percent variations

### Phase 4: Root Cause Identification
Compare results to identify patterns:
- All variations of a test fail → infrastructure/config issue
- Only primary variations fail → primary pod handling issue
- Only replica variations fail → replica sync issue
- Only high-intensity variations fail → threshold issue

## File Naming Convention

```
XX-test-name-Y.yaml

XX = Test number (01-19)
test-name = Original test name
Y = Variation (a, b, c, d, e)
```

Examples:
- `01-pod-failure-a.yaml` - Pod failure, variation A (replica)
- `05-network-partition-c.yaml` - Network partition, variation C (short)
- `18-stress-cpu-primary-e.yaml` - CPU stress, variation E (extended)

## Documentation Files

Created supporting documentation:
- **TEST-VARIATIONS-GUIDE.md** - Detailed guide to all 95 variations
- **This file** - Summary and usage strategy

## Next Steps

1. **Review TEST-VARIATIONS-GUIDE.md** for detailed parameter information
2. **Start with working test variations** (02, 08, 09, 12, 18, 19)
3. **Test replica variations** to understand target-specific issues
4. **Test intensity variations** to find failure thresholds
5. **Document results** in a test matrix
6. **Compare failing vs working scenarios** to identify differences

## Troubleshooting Tips

When running tests, monitor:
- **Pod status**: Watch for crashes, restarts, or pending states
- **Database connectivity**: Test queries during chaos
- **Replication lag**: Monitor WAL position on replicas
- **Leader election**: Check if new primary is elected
- **Recovery time**: Measure time to stability after chaos stops

## Quick Reference: Expected Results

Based on the README expectations:

### Should PASS (6 tests)
- Pod kill operations (immediate, clean termination)
- Complete network loss (TCP handles it gracefully)
- Network duplicates (TCP handles duplicates)
- DNS errors (caching helps)
- CPU stress (throttling managed)
- Memory stress (containers handle pressure)

### Likely to FAIL (13 tests)
- Pod failure (extended unavailability)
- Pod OOM (memory pressure triggers)
- Kill process (process crash recovery)
- Network partition (split-brain)
- Bandwidth limits (replication lag)
- Network delay (timeout-related)
- Network corruption (integrity issues)
- Time offset (timestamp issues)
- I/O latency (performance degradation)
- I/O faults (storage errors)
- I/O attr override (write permission issues)
- I/O data corruption (data integrity)
- Node reboot (cluster-wide outage)

## Version Information

- Target: KubeDB PostgreSQL 16.4-bookworm
- HA Mode: Hot secondary with 3 replicas
- Cluster Name: sqlserver-ag-cluster
- Namespace: demo
- Chaos Mesh: Latest

## Support Resources

Refer to:
- **README.md** - Original test descriptions and expected results
- **TEST-VARIATIONS-GUIDE.md** - Detailed parameter reference for each variation
- **Chaos Mesh Docs**: https://chaos-mesh.org/
- **KubeDB Docs**: https://kubedb.io/
