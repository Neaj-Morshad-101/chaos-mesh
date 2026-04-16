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

befor chaos:
sqlserver-ha-cluster-0  primary
sqlserver-ha-cluster-1  secondary
sqlserver-ha-cluster-2  secondary

after chaos:
sqlserver-ha-cluster-0  primary
sqlserver-ha-cluster-1  primary
sqlserver-ha-cluster-2  secondary

sqlserver-ha-cluster-0:
```bash
       1 PRIMARY                                                      890635E0-7979-491C-9CAB-61A27FA57E25 F961FA40-BDBD-211D-2E41-D377BF3CE482 HEALTHY                                                      CONNECTED                                                    ONLINE                                                      
       0 SECONDARY                                                    73AE0691-9870-4F86-A5BC-2FAFF65EA1F0 F961FA40-BDBD-211D-2E41-D377BF3CE482 NOT_HEALTHY                                                  DISCONNECTED                                                 NULL                                                        
       0 SECONDARY                                                    16E06FD7-6C65-4F09-86EE-68E67CE3790D F961FA40-BDBD-211D-2E41-D377BF3CE482 NOT_HEALTHY                                                  DISCONNECTED                                                 NULL                                                        

(3 rows affected)
1> use agdb;
2> go
Msg 988, Level 14, State 1, Server sqlserver-ha-cluster-0, Line 1
Unable to access database 'agdb' because it lacks a quorum of nodes for high availability. Try the operation again later.
1> 
```

sqlserver-ha-cluster-1: 
```bash
is_local role_desc                                                    replica_id                           group_id                             synchronization_health_desc                                  connected_state_desc                                         operational_state_desc
-------- ------------------------------------------------------------ ------------------------------------ ------------------------------------ ------------------------------------------------------------ ------------------------------------------------------------ ------------------------------------------------------------
       0 SECONDARY                                                    890635E0-7979-491C-9CAB-61A27FA57E25 F961FA40-BDBD-211D-2E41-D377BF3CE482 NOT_HEALTHY                                                  DISCONNECTED                                                 NULL                                                        
       1 PRIMARY                                                      73AE0691-9870-4F86-A5BC-2FAFF65EA1F0 F961FA40-BDBD-211D-2E41-D377BF3CE482 HEALTHY                                                      CONNECTED                                                    ONLINE                                                      
       0 SECONDARY                                                    16E06FD7-6C65-4F09-86EE-68E67CE3790D F961FA40-BDBD-211D-2E41-D377BF3CE482 HEALTHY                                                      CONNECTED                                                    NULL   
(3 rows affected)
```


DB is Critical <-> NotReady because of two primary  (one is healthy with quorum, another is unhealthy without quorum). Only qurum primary taking writes. 
We need to update replica role based on quorum, and update svc label in this schenario.

* **`io-latency-primary.yaml`**: Simulates a slow disk on the primary pod.
* **`stress-cpu-primary.yaml`**: Injects high CPU load on the primary.
* **`stress-memory-replica.yaml`**: Injects high memory load on a replica to test OOMKilled recovery.
* **`dns-error-from-client.yaml`**: Simulates DNS resolution failures from the client pod to the database service.