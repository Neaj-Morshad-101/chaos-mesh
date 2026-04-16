# Chaos Engineering Test Suite - Summary

## Overview

This test suite contains **19 comprehensive chaos engineering tests** designed to validate the resilience and high availability of KubeDB-managed PostgreSQL clusters. The tests are based on the chaos engineering scenarios from the provided test matrix.

## Test Coverage Matrix

| # | Test Category | Test Name | Chaos Type | Target | Expected Result |
|---|---------------|-----------|------------|--------|-----------------|
| 1 | Pod Chaos | Pod Failure | PodChaos | Primary | ❌ Fail |
| 2 | Pod Chaos | Pod Kill | PodChaos | Primary | ✅ Pass |
| 3 | Pod Chaos | Pod OOM | StressChaos | Primary | ❌ Fail |
| 4 | Pod Chaos | Kill Postgres Process | PodChaos | Primary | ❌ Fail |
| 5 | Network Chaos | Network Partition | NetworkChaos | Primary-secondary | ❌ Fail |
| 6 | Network Chaos | Network Bandwidth | NetworkChaos | Primary | ❌ Fail |
| 7 | Network Chaos | Network Delay | NetworkChaos | Primary | ❌ Fail |
| 8 | Network Chaos | Network Loss | NetworkChaos | Primary | ✅ Pass |
| 9 | Network Chaos | Network Duplicate | NetworkChaos | Primary | ✅ Pass |
| 10 | Network Chaos | Network Corrupt | NetworkChaos | Primary | ❌ Fail |
| 11 | Time Chaos | Time Offset | TimeChaos | Primary | ❌ Fail |
| 12 | DNS Chaos | DNS Error | DNSChaos | Primary | ✅ Pass |
| 13 | I/O Chaos | IO Latency | IOChaos | Primary | ❌ Fail |
| 14 | I/O Chaos | IO Fault | IOChaos | Primary | ❌ Fail |
| 15 | I/O Chaos | IO AttrOverride | IOChaos | Primary | ❌ Fail |
| 16 | I/O Chaos | IO Mistake | IOChaos | Primary | ❌ Fail |
| 17 | Node Chaos | Nodes Reboot | NodeChaos | All Nodes | ❌ Fail |
| 18 | Resource Chaos | Stress CPU | StressChaos | Primary | ✅ Pass |
| 19 | Resource Chaos | Stress Memory | StressChaos | Replica | ✅ Pass |

## Test Statistics

- **Total Tests**: 19
- **Expected to Pass**: 6 (31.6%)
- **Expected to Fail**: 13 (68.4%)

### By Category

| Category | Total | Pass | Fail |
|----------|-------|------|------|
| Pod Chaos | 4 | 1 | 3 |
| Network Chaos | 6 | 2 | 4 |
| Time/DNS Chaos | 2 | 1 | 1 |
| I/O Chaos | 4 | 0 | 4 |
| Node/Resource Chaos | 3 | 2 | 1 |

## Quick Start

### 1. Prerequisites Check
```bash
cd tests
./run-tests.sh check
```

### 2. View Cluster Status
```bash
./run-tests.sh status
```

### 3. Run Individual Test
```bash
./run-tests.sh test 02-pod-kill.yaml
```

### 4. Run Category Tests
```bash
# Pod chaos tests
./run-tests.sh pod

# Network chaos tests
./run-tests.sh network

# I/O chaos tests
./run-tests.sh io

# Resource stress tests
./run-tests.sh stress
```

### 5. Run All Tests
```bash
./run-tests.sh all
```

### 6. Monitor Cluster
```bash
./run-tests.sh monitor
```

### 7. Cleanup
```bash
./run-tests.sh cleanup
```

## Test Descriptions

### Pod Chaos Tests (01-04)

1. **Pod Failure** - Simulates pod failure for 5 minutes
   - Tests: Extended unavailability scenarios
   - Expected: Cluster should mark pod as failed and initiate recovery

2. **Pod Kill** - Kills primary pod immediately
   - Tests: Rapid failover capability
   - Expected: secondary promotion within 2-10 seconds

3. **Pod OOM** - Triggers out-of-memory condition
   - Tests: Memory limit handling
   - Expected: Pod restart, potential data loss scenarios

4. **Kill Postgres Process** - Terminates PostgreSQL process
   - Tests: Process crash recovery
   - Expected: PostgreSQL restart, coordinator handles recovery

### Network Chaos Tests (05-10)

5. **Network Partition** - Isolates primary from secondary pods
   - Tests: Split-brain prevention
   - Expected: Leader election, potential split-brain

6. **Network Bandwidth** - Limits bandwidth to 1mbps
   - Tests: Replication lag under congestion
   - Expected: Increased lag, potential timeout

7. **Network Delay** - Adds 500ms latency
   - Tests: High-latency tolerance
   - Expected: Slow replication, query delays

8. **Network Loss** - 100% packet loss
   - Tests: Complete network failure
   - Expected: Failover triggers, secondary promotion

9. **Network Duplicate** - 50% packet duplication
   - Tests: TCP duplicate handling
   - Expected: TCP layer handles gracefully

10. **Network Corrupt** - 50% packet corruption
    - Tests: Data integrity under corruption
    - Expected: Connection failures, retransmissions

### Time and DNS Chaos Tests (11-12)

11. **Time Offset** - Shifts clock by -2 hours
    - Tests: Time drift scenarios
    - Expected: Replication issues, certificate problems

12. **DNS Error** - Blocks DNS resolution
    - Tests: DNS failure resilience
    - Expected: Connection failures, cached entries help

### I/O Chaos Tests (13-16)

13. **IO Latency** - Adds 500ms storage latency
    - Tests: Degraded storage performance
    - Expected: Slow writes, query timeouts

14. **IO Fault** - Injects I/O errors (EIO)
    - Tests: Storage device failures
    - Expected: Write failures, potential corruption

15. **IO AttrOverride** - Sets files to read-only
    - Tests: Permission issues
    - Expected: Write failures, PostgreSQL errors

16. **IO Mistake** - Corrupts data on storage
    - Tests: Data corruption scenarios
    - Expected: Checksum failures, data loss

### Node and Resource Chaos Tests (17-19)

17. **Nodes Reboot** - Reboots all cluster nodes
    - Tests: Datacenter-wide outage
    - Expected: Complete cluster unavailability

18. **Stress CPU** - 90% CPU load on primary
    - Tests: CPU pressure handling
    - Expected: Throttling, slower queries

19. **Stress Memory** - 800Mi memory pressure on replica
    - Tests: Memory pressure on secondary
    - Expected: Performance degradation, no OOM

## Validation Criteria

For each test, validate:

### During Test
- ✓ Chaos experiment applies successfully
- ✓ Target pods are affected
- ✓ Monitoring shows expected behavior

### After Test
- ✓ Cluster returns to healthy state
- ✓ All pods are running
- ✓ Replication is working
- ✓ Data integrity maintained
- ✓ No data loss

### Commands for Validation

```bash
# Check cluster health
kubectl get postgres sqlserver-ag-cluster -n demo

# Check pod status
kubectl get pods -n demo -l app.kubernetes.io/instance=sqlserver-ag-cluster

# Check replication status
PRIMARY_POD=$(kubectl get pods -n demo -l kubedb.com/role=primary -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n demo $PRIMARY_POD -- psql -c "SELECT * FROM mssql_stat_replication;"

# Check coordinator logs
kubectl logs -n demo $PRIMARY_POD -c mssql-coordinator --tail=50
```

## Expected Failover Behavior

Based on KubeDB documentation:

1. **Normal Failover**: 2-10 seconds
   - Raft detects primary failure
   - Leader election completes
   - New primary promoted

2. **Delayed Failover**: Up to 45 seconds
   - Highest LSN pod unavailable
   - System waits for recovery
   - Manual force-failover may be needed

## Common Issues and Solutions

### Issue: Test Not Applying
**Solution**: Check Chaos Mesh permissions and target pod existence

### Issue: Cluster Not Recovering
**Solution**: Check KubeDB operator logs and mssql-coordinator logs

### Issue: Replication Broken
**Solution**: Verify network connectivity and storage health

### Issue: Data Loss Detected
**Solution**: Check WAL settings and backup configurations

## Monitoring During Tests

### Key Metrics to Watch

1. **Failover Time**: Time from primary failure to secondary promotion
2. **Replication Lag**: WAL replication delay
3. **Connection Count**: Active client connections
4. **Query Performance**: Query execution time
5. **Error Rate**: Failed queries/connections

### Monitoring Commands

```bash
# Watch pod roles
watch -n 2 "kubectl get pods -n demo -o jsonpath='{range .items[*]}{.metadata.name} {.metadata.labels.kubedb\\.com/role}{\"\n\"}{end}'"

# Monitor replication lag
kubectl exec -n demo $PRIMARY_POD -- psql -c "SELECT client_addr, state, sync_state, replay_lag FROM mssql_stat_replication;"

# Check cluster events
kubectl get events -n demo --sort-by='.lastTimestamp' | grep sqlserver-ag-cluster
```

## Best Practices

1. **Run tests in non-production** environments first
2. **Monitor logs** during test execution
3. **Document results** for each test run
4. **Take backups** before running destructive tests
5. **Run tests individually** to isolate issues
6. **Wait for recovery** between tests
7. **Validate data integrity** after each test

## Integration with CI/CD

To integrate these tests into your CI/CD pipeline:

```yaml
# Example GitHub Actions workflow
name: Chaos Tests
on: [push, pull_request]
jobs:
  chaos-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Kubernetes
        uses: helm/kind-action@v1
      - name: Install Chaos Mesh
        run: |
          kubectl apply -f https://mirrors.chaos-mesh.org/latest/crd.yaml
          kubectl apply -f https://mirrors.chaos-mesh.org/latest/chaos-mesh.yaml
      - name: Deploy PostgreSQL
        run: kubectl apply -f setup/kubedb-postgres.yaml
      - name: Run Chaos Tests
        run: cd tests && ./run-tests.sh all
```

## References

- [KubeDB PostgreSQL Documentation](https://kubedb.com/docs/latest/guides/postgres/)
- [Chaos Mesh Documentation](https://chaos-mesh.org/docs/)
- [PostgreSQL Replication](https://www.postgresql.org/docs/current/warm-secondary.html)
- [Raft Consensus Algorithm](https://raft.github.io/)

## Contributing

To add new tests:

1. Create YAML file following naming convention
2. Add test description to README.md
3. Update this summary document
4. Test thoroughly
5. Submit pull request

## License

Part of the KubeDB PostgreSQL chaos engineering test suite.
