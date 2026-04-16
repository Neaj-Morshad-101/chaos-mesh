# Test Validation Checklist

Use this checklist when running each chaos test to ensure thorough validation and documentation.

## Pre-Test Checklist

### Environment Verification
- [ ] Kubernetes cluster is healthy
- [ ] KubeDB operator is running
- [ ] Chaos Mesh is installed and operational
- [ ] PostgreSQL cluster is in Ready state
- [ ] All pods are Running (check: `kubectl get pods -n demo`)
- [ ] Replication is working (check mssql_stat_replication)
- [ ] Monitoring is configured and accessible
- [ ] Backup is recent (within last 24 hours)

### Test Preparation
- [ ] Test name documented: _______________
- [ ] Expected result documented: _______________
- [ ] Start time recorded: _______________
- [ ] Current primary pod identified: _______________
- [ ] Baseline metrics captured:
  - [ ] Query response time: _______________
  - [ ] Replication lag: _______________
  - [ ] CPU usage: _______________
  - [ ] Memory usage: _______________
  - [ ] Active connections: _______________

### Safety Checks
- [ ] This is NOT a production environment
- [ ] Team members notified about test
- [ ] Rollback procedure documented
- [ ] Emergency contacts available
- [ ] Time allocated (sufficient for test + recovery)

---

## During-Test Checklist

### Test Execution
- [ ] Chaos experiment applied successfully
- [ ] Experiment status is "Running" or "Active"
- [ ] Target pods affected as expected
- [ ] Timestamp of chaos start: _______________

### Monitoring Activities
- [ ] Pod status being monitored (watch command running)
- [ ] Logs being captured (coordinator and postgres)
- [ ] Metrics being recorded
- [ ] Failover events being documented

### Key Observations
- [ ] Primary pod behavior: _______________
- [ ] secondary pod behavior: _______________
- [ ] Failover triggered: Yes / No
- [ ] Time to failover: _______________
- [ ] New primary pod: _______________
- [ ] Error messages observed: _______________
- [ ] Unexpected behaviors: _______________

---

## Post-Test Checklist

### Immediate Verification
- [ ] Chaos experiment deleted/completed
- [ ] All pods returned to Running state
- [ ] Exactly 1 pod has role=primary
- [ ] Exactly 2 pods have role=secondary
- [ ] No pods in CrashLoopBackOff or Error state
- [ ] No pending PVCs or storage issues

### Cluster Health
- [ ] PostgreSQL cluster status is "Ready"
- [ ] Database is accessible from primary pod
- [ ] Can connect via service endpoint
- [ ] Replication is active (check mssql_stat_replication)
- [ ] No replication lag (or acceptable lag)
- [ ] No split-brain condition detected

### Data Integrity
- [ ] Test table still exists
- [ ] Row count matches expected
- [ ] Can insert new data
- [ ] New data replicates to secondary
- [ ] No corruption detected
- [ ] Checksums valid (if enabled)

### Functional Testing
```sql
-- Run these queries and record results
-- 1. Check replication
SELECT client_addr, state, sync_state, replay_lag 
FROM mssql_stat_replication;
Result: _______________

-- 2. Check for conflicts
SELECT * FROM mssql_stat_database_conflicts 
WHERE datname = 'postgres';
Result: _______________

-- 3. Check WAL status
SELECT mssql_current_wal_lsn();
Result: _______________

-- 4. Test write operation
CREATE TABLE test_recovery_TIMESTAMP (id INT);
INSERT INTO test_recovery_TIMESTAMP VALUES (1);
Result: _______________

-- 5. Verify replication
-- On secondary pod:
SELECT COUNT(*) FROM test_recovery_TIMESTAMP;
Result: _______________
```

### Performance Metrics (Post-Test)
- [ ] Query response time: _______________
- [ ] Replication lag: _______________
- [ ] CPU usage: _______________
- [ ] Memory usage: _______________
- [ ] Active connections: _______________
- [ ] Compared to baseline: Better / Same / Worse

### Log Analysis
- [ ] Operator logs reviewed
- [ ] mssql-coordinator logs reviewed
- [ ] PostgreSQL logs reviewed
- [ ] Chaos Mesh logs reviewed
- [ ] Notable errors documented: _______________
- [ ] Warning messages documented: _______________

### Time Metrics
- [ ] Test end time: _______________
- [ ] Total test duration: _______________
- [ ] Time to detect failure: _______________
- [ ] Time to initiate failover: _______________
- [ ] Time to complete failover: _______________
- [ ] Time to full recovery: _______________

---

## Test Result Classification

### Test Outcome
- [ ] **PASS** - Cluster recovered automatically, no data loss
- [ ] **PASS with Degradation** - Recovered but with performance impact
- [ ] **PARTIAL PASS** - Recovered with manual intervention
- [ ] **FAIL** - Did not recover or data loss occurred
- [ ] **BLOCKED** - Could not complete test due to: _______________

### Failover Classification (if applicable)
- [ ] **Fast Failover** (2-10 seconds) - Expected behavior
- [ ] **Slow Failover** (10-45 seconds) - Acceptable
- [ ] **Delayed Failover** (>45 seconds) - Needs investigation
- [ ] **Failed Failover** - Required manual intervention
- [ ] **No Failover** - Cluster continued with degraded primary

### Impact Assessment
- [ ] **No Impact** - Transparent to applications
- [ ] **Minimal Impact** - Brief connection interruption
- [ ] **Moderate Impact** - Service degradation during test
- [ ] **Severe Impact** - Extended outage or data issues
- [ ] **Critical Impact** - Data loss or corruption

---

## Issue Documentation

### Issues Encountered
1. Issue: _______________
   Severity: Critical / High / Medium / Low
   Resolution: _______________

2. Issue: _______________
   Severity: Critical / High / Medium / Low
   Resolution: _______________

3. Issue: _______________
   Severity: Critical / High / Medium / Low
   Resolution: _______________

### Follow-Up Actions Required
- [ ] Action: _______________
      Owner: _______________
      Deadline: _______________

- [ ] Action: _______________
      Owner: _______________
      Deadline: _______________

### Bugs/Improvements Identified
- [ ] Bug report filed: _______________
- [ ] Improvement suggestion: _______________
- [ ] Documentation update needed: _______________

---

## Cleanup Verification

### Chaos Resources
- [ ] All chaos experiments deleted
- [ ] No orphaned chaos resources
- [ ] Chaos Mesh pods healthy
- [ ] No chaos-related errors in logs

### Database Cleanup
- [ ] Test tables dropped (if applicable)
- [ ] Test data removed (if applicable)
- [ ] Temporary configurations reverted
- [ ] Storage usage acceptable

### Environment Reset
- [ ] Cluster returned to baseline state
- [ ] Ready for next test
- [ ] Monitoring data saved
- [ ] Logs archived

---

## Documentation

### Test Report
- [ ] Test summary written
- [ ] Screenshots captured
- [ ] Logs saved to: _______________
- [ ] Metrics exported to: _______________
- [ ] Report shared with: _______________

### Lessons Learned
1. What worked well: _______________

2. What didn't work: _______________

3. Unexpected findings: _______________

4. Recommendations: _______________

### Knowledge Base Update
- [ ] Internal wiki updated
- [ ] Runbook updated (if applicable)
- [ ] Team training needed: Yes / No
- [ ] Documentation improved

---

## Sign-Off

### Test Execution
- Executed by: _______________
- Date: _______________
- Time: _______________
- Signature: _______________

### Test Review
- Reviewed by: _______________
- Date: _______________
- Approved: Yes / No
- Comments: _______________

---

## Quick Commands for Validation

```bash
# Cluster health
kubectl get postgres sqlserver-ag-cluster -n demo
kubectl get pods -n demo -l app.kubernetes.io/instance=sqlserver-ag-cluster

# Pod roles
kubectl get pods -n demo -o custom-columns=NAME:.metadata.name,ROLE:.metadata.labels.kubedb\\.com/role

# Replication status
PRIMARY=$(kubectl get pods -n demo -l kubedb.com/role=primary -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n demo $PRIMARY -- psql -c "SELECT * FROM mssql_stat_replication;"

# Check for issues
kubectl exec -n demo $PRIMARY -- psql -c "SELECT * FROM mssql_stat_database_conflicts WHERE datname='postgres';"

# Test write
kubectl exec -n demo $PRIMARY -- psql -c "CREATE TABLE test_$(date +%s) (id INT); INSERT INTO test_$(date +%s) VALUES (1);"

# Check logs
kubectl logs -n demo $PRIMARY -c mssql-coordinator --tail=50
kubectl logs -n demo $PRIMARY -c postgres --tail=50

# Chaos status
kubectl get chaos -n chaos-mesh
kubectl describe <chaos-type> <chaos-name> -n chaos-mesh
```

---

## Notes Section

Use this space for additional observations, context, or details:

_______________________________________________________________________________

_______________________________________________________________________________

_______________________________________________________________________________

_______________________________________________________________________________

_______________________________________________________________________________

