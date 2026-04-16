# Chaos Engineering Tests for KubeDB PostgreSQL HA Cluster

This directory contains comprehensive chaos engineering tests designed to validate the resilience and high availability of KubeDB-managed PostgreSQL clusters.

## Prerequisites

1. **Chaos Mesh Installed**: Ensure Chaos Mesh is installed in your Kubernetes cluster
   ```bash
   kubectl apply -f https://mirrors.chaos-mesh.org/latest/crd.yaml
   kubectl apply -f https://mirrors.chaos-mesh.org/latest/chaos-mesh.yaml
   ```

2. **PostgreSQL HA Cluster**: Deploy the PostgreSQL cluster using the provided configuration
   ```bash
   kubectl apply -f ../setup/kubedb-postgres.yaml
   ```

3. **Verify Cluster Status**:
   ```bash
   kubectl get mssql -n demo
   kubectl get pods -n demo -l app.kubernetes.io/instance=sqlserver-ag-cluster
   ```

## Test Scenarios

### Pod-Level Chaos Tests

| Test File | Test Name | Description | Expected Result |
|-----------|-----------|-------------|-----------------|
| `01-pod-failure.yaml` | Pod Failure | Inject pod-failure fault into Primary Pod for 5 minutes | **FAIL** - Extended unavailability |
| `02-pod-kill.yaml` | Pod Kill | Kill Primary Pod to simulate operational mistakes | **PASS** - Quick failover (2-10s) |
| `03-pod-oom.yaml` | Pod OOM | Continuously inject OOM faults into Primary Pod | **FAIL** - Memory pressure issues |
| `04-kill-postgres-process.yaml` | Kill Postgres Process | Kill PostgreSQL process inside Primary Pod | **FAIL** - Process crash recovery |

### Network Chaos Tests

| Test File | Test Name | Description | Expected Result |
|-----------|-----------|-------------|-----------------|
| `05-network-partition.yaml` | Network Partition | Simulate network partition between Primary and secondary pods | **FAIL** - Split-brain scenarios |
| `06-network-bandwidth.yaml` | Network Bandwidth | Restrict network bandwidth on Primary Pod (1mbps) | **FAIL** - Replication lag |
| `07-network-delay.yaml` | Network Delay | Inject 500ms network latency on Primary Pod | **FAIL** - High-latency issues |
| `08-network-loss.yaml` | Network Loss | Inject 100% packet loss on Primary Pod | **PASS** - Handles complete loss |
| `09-network-duplicate.yaml` | Network Duplicate | Inject 50% duplicate packets on Primary Pod | **PASS** - TCP handles duplicates |
| `10-network-corrupt.yaml` | Network Corrupt | Inject 50% packet corruption on Primary Pod | **FAIL** - Data integrity issues |

### Time and DNS Chaos Tests

| Test File | Test Name | Description | Expected Result |
|-----------|-----------|-------------|-----------------|
| `11-time-offset.yaml` | TimeOffset | Offset system clock by -2 hours on Primary Pod | **FAIL** - Time drift issues |
| `12-dns-error.yaml` | DNS Error | Inject DNS resolution faults on Primary Pod | **PASS** - DNS caching helps |

### I/O Chaos Tests

| Test File | Test Name | Description | Expected Result |
|-----------|-----------|-------------|-----------------|
| `13-io-latency.yaml` | IO Latency | Inject 500ms I/O latency on Primary Pod storage | **FAIL** - Degraded performance |
| `14-io-fault.yaml` | IO Fault | Inject I/O faults (EIO errors) on Primary Pod | **FAIL** - Storage failures |
| `15-io-attr-override.yaml` | IO AttrOverride | Set files to read-only (insufficient permissions) | **FAIL** - Write permission issues |
| `16-io-mistake.yaml` | IO Mistake | Inject random data errors on Primary Pod storage | **FAIL** - Data corruption |

### Node and Resource Chaos Tests

| Test File | Test Name | Description | Expected Result |
|-----------|-----------|-------------|-----------------|
| `17-node-reboot.yaml` | Nodes Reboot | Reboot all nodes to simulate datacenter power outage | **FAIL** - Cluster-wide outage |
| `18-stress-cpu-primary.yaml` | Stress CPU | Stress CPU (90% load) on Primary Pod | **PASS** - CPU throttling handled |
| `19-stress-memory-replica.yaml` | Stress Memory | Stress memory (800Mi) on Replica Pod | **PASS** - Memory pressure handled |

## Running the Tests

### Run Individual Test

To run a specific chaos test:

```bash
# Apply the chaos experiment
kubectl apply -f tests/02-pod-kill.yaml

# Watch the pods to observe behavior
watch kubectl get pods -n demo -o wide

# Check chaos experiment status
kubectl get podchaos -n chaos-mesh
kubectl describe podchaos mssql-primary-pod-kill -n chaos-mesh

# Delete the experiment when done
kubectl delete -f tests/02-pod-kill.yaml
```

### Run All Tests Sequentially

```bash
# Create a script to run all tests
for test in tests/*.yaml; do
  echo "Running test: $test"
  kubectl apply -f $test
  sleep 300  # Wait 5 minutes
  kubectl delete -f $test
  sleep 60   # Wait 1 minute between tests
done
```

### Monitor PostgreSQL Cluster During Tests

```bash
# Watch pod status and roles
watch 'kubectl get pods -n demo -o jsonpath='"'"'{range .items[*]}{.metadata.name} {.metadata.labels.kubedb\\.com/role}{"\n"}{end}'"'"''

# Check replication status from primary
PRIMARY_POD=$(kubectl get pods -n demo -l kubedb.com/role=primary -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it -n demo $PRIMARY_POD -- psql -c "SELECT * FROM mssql_stat_replication;"

# Monitor failover logs
kubectl logs -n demo -l app.kubernetes.io/instance=sqlserver-ag-cluster -c mssql-coordinator --tail=50 -f
```

## Test Result Analysis

### Expected Behavior

1. **Pod Kill (PASS)**: When primary pod is killed, KubeDB should automatically promote a secondary to primary within 2-10 seconds.

2. **Network Loss (PASS)**: Complete packet loss should trigger failover as the primary becomes unreachable.

3. **Network Partition (FAIL)**: Split-brain scenarios may occur if both partitions believe they are primary.

4. **CPU/Memory Stress (PASS)**: Resource pressure should be handled gracefully with throttling.

### Monitoring Metrics

During tests, monitor:

- **Failover Time**: Time taken for secondary to become primary
- **Data Integrity**: Verify no data loss after recovery
- **Replication Lag**: Check lag between primary and secondary
- **Application Availability**: Test client connections during chaos

```bash
# Test client connection
kubectl run mssql-client --rm -it --image=postgres:16 -n demo -- bash
# Inside container:
psql -h sqlserver-ag-cluster.demo.svc.cluster.local -U postgres -d postgres
```

## Important Notes

### Node Reboot Test

The `17-node-reboot.yaml` requires actual node names. Update the file with your cluster's node names:

```bash
# Get node names where postgres pods are running
kubectl get pods -n demo -o wide | grep sqlserver-ag-cluster

# Edit the file and replace node names
vim tests/17-node-reboot.yaml
```

### Storage Path Considerations

I/O chaos tests use `/var/lib/postgresql/data` as the volume path. Verify this matches your PostgreSQL configuration:

```bash
kubectl exec -n demo <pod-name> -- df -h | grep postgresql
```

### Chaos Mesh Permissions

Ensure Chaos Mesh has proper RBAC permissions:

```bash
kubectl auth can-i create podchaos --as=system:serviceaccount:chaos-mesh:chaos-controller-manager -n demo
```

## Cleanup

Remove all chaos experiments:

```bash
# Delete all chaos experiments
kubectl delete podchaos,networkchaos,iochaos,stresschaos,timechaos,dnschaos,nodechaos -n chaos-mesh --all

# Verify cleanup
kubectl get chaos -n chaos-mesh
```

## Troubleshooting

### Chaos Experiment Not Working

1. Check Chaos Mesh controller logs:
   ```bash
   kubectl logs -n chaos-mesh -l app.kubernetes.io/component=controller-manager
   ```

2. Verify target pods exist:
   ```bash
   kubectl get pods -n demo -l app.kubernetes.io/instance=sqlserver-ag-cluster
   ```

3. Check experiment status:
   ```bash
   kubectl describe <chaos-type> <chaos-name> -n chaos-mesh
   ```

### PostgreSQL Not Recovering

1. Check KubeDB operator logs:
   ```bash
   kubectl logs -n kubedb -l app.kubernetes.io/name=kubedb-ops-manager
   ```

2. Check mssql-coordinator logs:
   ```bash
   kubectl logs -n demo <pod-name> -c mssql-coordinator
   ```

3. Manually verify cluster health:
   ```bash
   kubectl exec -n demo <primary-pod> -- psql -c "SELECT * FROM mssql_stat_replication;"
   ```

## Additional Resources

- [KubeDB PostgreSQL Documentation](https://kubedb.com/docs/latest/guides/postgres/)
- [Chaos Mesh Documentation](https://chaos-mesh.org/docs/)
- [PostgreSQL High Availability](https://www.postgresql.org/docs/current/high-availability.html)
- [KubeDB Failover Process](../postgres/failure-and-disaster-recovery/failure_and_disaster_recovery.md)

## Contributing

When adding new chaos tests:

1. Follow the naming convention: `<number>-<test-name>.yaml`
2. Include detailed comments in the YAML
3. Update this README with test description and expected results
4. Test thoroughly before committing

## License

This testing suite is part of the KubeDB chaos engineering validation project.
