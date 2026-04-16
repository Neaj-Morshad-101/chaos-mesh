Below is a **real-world, production-grade guide** to doing **Chaos Mesh testing for a KubeDB MSSQLServer Availability Group (AG)**. I’ll walk you through:

1. Architecture understanding (critical for chaos design)
2. Environment setup (KubeDB + MSSQL AG)
3. Chaos experiment design (what actually matters)
4. Step-by-step Chaos Mesh experiments
5. Validation strategy (THIS is where most people fail)
6. Advanced scenarios (network partition, split-brain, etc.)

---

# 🧠 1. Understand what you are testing (VERY important)

A **KubeDB MSSQLServer AG cluster** is:

* 1 **primary replica**
* N **secondary replicas**
* Automatic **failover via leader election**
* Data replication across nodes ([kubedb.com][1])

KubeDB handles:

* AG creation
* Database sync
* Failover orchestration ([kubedb.com][2])

👉 So your chaos testing goal is:

> “Does the system maintain availability + consistency during failures?”

---

# 🧱 2. Environment Setup (baseline)

## ✅ 2.1 Install KubeDB (with MSSQL support)

```bash
helm install kubedb oci://ghcr.io/appscode-charts/kubedb \
  --namespace kubedb --create-namespace \
  --set global.featureGates.MSSQLServer=true
```

---

## ✅ 2.2 Install cert-manager (required)

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
```

KubeDB uses it for:

* TLS
* AG communication ([kubedb.com][2])

---

## ✅ 2.3 Create MSSQL AG cluster

Example:

```yaml
apiVersion: kubedb.com/v1alpha2
kind: MSSQLServer
metadata:
  name: mssql-ag
  namespace: demo
spec:
  version: "2022-cu12"
  replicas: 3
  topology:
    mode: AvailabilityGroup
    availabilityGroup:
      databases:
        - testdb
```

Apply:

```bash
kubectl create ns demo
kubectl apply -f mssql-ag.yaml
```

---

## ✅ 2.4 Verify cluster

```bash
kubectl get pods -n demo
```

Check roles:

```bash
kubectl get pods -n demo \
  -l app.kubernetes.io/instance=mssql-ag \
  -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.labels.kubedb\.com/role}{"\n"}{end}'
```

---

## ✅ 2.5 Insert test data

```bash
kubectl exec -it mssql-ag-0 -n demo -- bash
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "<pass>"
```

```sql
CREATE DATABASE chaosdb;
USE chaosdb;
CREATE TABLE t (id INT, val NVARCHAR(100));
INSERT INTO t VALUES (1, 'before-chaos');
```

---

# 🔥 3. Chaos Testing Strategy (don’t skip this)

You should test **failure classes**, not random chaos:

### 🧨 A. Node/Pod failure

* Primary dies → failover happens?

### 🌐 B. Network issues

* Latency
* Partition
* Packet loss

### 💾 C. Resource pressure

* CPU stress
* Memory pressure

### 🔁 D. Stateful issues

* Disk I/O latency
* replication lag

---

# ⚙️ 4. Chaos Mesh Experiments

---

## 🧪 4.1 Pod Kill (Primary Failover Test)

This is your **baseline test**.

```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: PodChaos
metadata:
  name: kill-primary
  namespace: demo
spec:
  action: pod-kill
  mode: one
  selector:
    labelSelectors:
      kubedb.com/role: primary
```

Apply:

```bash
kubectl apply -f pod-kill.yaml
```

---

### ✅ Expected behavior

* Primary pod dies
* New primary elected automatically ([kubedb.com][2])
* Writes resume

---

### 🔍 Validate

```bash
kubectl get pods -n demo -L kubedb.com/role
```

Check DB:

```sql
INSERT INTO t VALUES (2, 'after-failover');
SELECT * FROM t;
```

---

## 🧪 4.2 Network Latency (Replication Stress)

```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: NetworkChaos
metadata:
  name: network-delay
  namespace: demo
spec:
  action: delay
  mode: all
  selector:
    labelSelectors:
      app.kubernetes.io/instance: mssql-ag
  delay:
    latency: "200ms"
    correlation: "100"
```

---

### ✅ What this tests

* replication lag
* query latency
* failover sensitivity

---

## 🧪 4.3 Network Partition (MOST IMPORTANT)

Simulate **split brain risk**

```yaml
kind: NetworkChaos
apiVersion: chaos-mesh.org/v1alpha1
metadata:
  name: partition
  namespace: demo
spec:
  action: partition
  mode: all
  selector:
    labelSelectors:
      kubedb.com/role: primary
  direction: both
  target:
    selector:
      labelSelectors:
        kubedb.com/role: secondary
    mode: all
```

---

### ✅ Expected

* primary isolated
* secondaries may elect new primary
* system should avoid split-brain

---

## 🧪 4.4 CPU Stress (resource pressure)

```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: StressChaos
metadata:
  name: cpu-stress
  namespace: demo
spec:
  mode: one
  selector:
    labelSelectors:
      kubedb.com/role: primary
  stressors:
    cpu:
      workers: 2
      load: 80
```

---

## 🧪 4.5 I/O Chaos (advanced)

```yaml
kind: IOChaos
apiVersion: chaos-mesh.org/v1alpha1
metadata:
  name: io-delay
  namespace: demo
spec:
  action: latency
  mode: one
  selector:
    labelSelectors:
      kubedb.com/role: primary
  delay: "100ms"
```

---

# 🧪 5. Validation Checklist (THIS is the real test)

After every chaos experiment:

### ✅ 1. Failover correctness

* Only ONE primary exists

### ✅ 2. Data consistency

```sql
SELECT COUNT(*) FROM t;
```

No data loss.

---

### ✅ 3. Write availability

* Can app still write?

---

### ✅ 4. Replication health

* Secondary catches up

---

### ✅ 5. Recovery time (RTO)

Measure:

```bash
time until new primary is ready
```

---

# ⚠️ 6. Real-world pitfalls (learned the hard way)

From real ops + community:

> AG systems are complex and require monitoring of sync state and failover behavior ([Reddit][3])

Common issues:

### ❌ Split brain

* Happens with bad network partition handling

### ❌ Replica lag

* Under network delay

### ❌ Failover takes too long

* Misconfigured election

---

# 🚀 7. Advanced Chaos Scenarios (high value)

### 🔥 Multi-failure chaos

* Kill primary + add network delay

### 🌍 Distributed AG testing

* Cross-cluster failure (if using DistributedAG) ([kubedb.com][1])

### 🧪 Backup/restore chaos

* Kill during backup

---

# 🧠 8. What “success” looks like

Your system passes chaos testing if:

* ✅ Automatic failover works
* ✅ No data loss
* ✅ Writes resume quickly
* ✅ No split-brain
* ✅ Replicas resync

---

# 🧭 Final Advice (important)

Start simple:

1. Pod kill
2. Network delay
3. Network partition

Only then go advanced.

---

If you want, I can:

* give you a **ready-made GitOps repo (Chaos + KubeDB YAMLs)**
* or design a **full chaos test plan for production-grade validation (with metrics + Prometheus + SLOs)**

[1]: https://kubedb.com/docs/v2026.2.26/guides/mssqlserver/concepts/mssqlserver/?utm_source=chatgpt.com "MSSQLServer CRD"
[2]: https://kubedb.com/docs/v2025.10.17/guides/mssqlserver/clustering/ag_cluster/?utm_source=chatgpt.com "SQL Server Availability Group Cluster Guide"
[3]: https://www.reddit.com/r/SQLServer/comments/1e65bkq?utm_source=chatgpt.com "Availability Group vs Failover Cluster SQL maitenance comparision"
