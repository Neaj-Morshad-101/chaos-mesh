# Single Experiments (`1-single-experiments/`)

## **`pod-kill-primary.yaml`**: Kills the primary pod to test automatic failover.   
**Success:**   
* Primary pod dies      
* New primary elected automatically      
* Writes resume  
* The primary pod is killed, and the system successfully promotes a replica to primary, maintaining availability. The killed primary pod is restarted and rejoins the cluster as a replica without issues.

## **`network-latency-primary-to-replicas.yaml`**: Adds 150ms latency between the primary and replicas to test replication lag.

**Success:**
### What happened

* Primary stays **unchanged**
* All pods remain **Running**
* Replication continues (**no stop**)
* Secondary replicas may show **lag**
* Queries become **slower (higher latency)**
* After chaos stops → replicas **catch up automatically**

---

# What NOT happened

* No **failover triggered**
* No **data loss**
* No **split-brain (multiple primaries)**
* No pod crashloop / restart loop
* No replication permanently stuck
* No write failures in app

---

```
commands: 
kubectl get pods -n demo \
        -l app.kubernetes.io/instance=sqlserver-ag-cluster \
        -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.labels.kubedb\.com/role}{"\n"}{end}'
sqlserver-ag-cluster-0	primary
sqlserver-ag-cluster-1	secondary
sqlserver-ag-cluster-2	secondary

watch -n 1 "kubectl get pods -n demo \
  -l app.kubernetes.io/instance=sqlserver-ag-cluster \
  -o jsonpath='{range .items[*]}{.metadata.name}{\"\\t\"}{.metadata.labels.kubedb\\.com/role}{\"\\n\"}{end}'"


➤ kubectl exec -it sqlserver-ag-cluster-0 -n demo -- bash
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P $MSSQL_SA_PASSWORD -No -Q "
SELECT DB_NAME(database_id) AS database_name, 
       synchronization_state_desc, 
       synchronization_health_desc
FROM sys.dm_hadr_database_replica_states;
GO
"

watch -n 2 "/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P \$MSSQL_SA_PASSWORD -No -Q \"
SELECT DB_NAME(database_id) AS db,
       synchronization_state_desc,
       synchronization_health_desc
FROM sys.dm_hadr_database_replica_states;
\""

USE agdb;
CREATE TABLE t (id INT, val NVARCHAR(100));
INSERT INTO t VALUES (1, 'before-chaos-replication-latency');
INSERT INTO t VALUES (1, 'during-chaos-replication-latency');
INSERT INTO t VALUES (1, 'after-chaos-replication-latency');

```

* **`network-partition-primary.yaml`**: Isolates the primary from replicas to test split-brain prevention.
* **`io-latency-primary.yaml`**: Simulates a slow disk on the primary pod.
* **`stress-cpu-primary.yaml`**: Injects high CPU load on the primary.
* **`stress-memory-replica.yaml`**: Injects high memory load on a replica to test OOMKilled recovery.
* **`dns-error-from-client.yaml`**: Simulates DNS resolution failures from the client pod to the database service.