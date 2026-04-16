# Chaos Engineering for KubeDB SQL Server Database Clusters

This repository contains a comprehensive set of [Chaos Mesh](https://chaos-mesh.org/) experiments designed to test the resilience and high-availability of a [KubeDB](https://kubedb.com/)-managed SQL Server cluster on Kubernetes.

The experiments are structured to increase in complexity, from single fault injections to complex, scheduled workflows.

## Directory Structure

* `/setup`: Contains manifests for deploying the target HA SQL Server cluster and a client pod.
* `/1-single-experiments`: Contains individual, one-off chaos experiments for various failure types.
* `/2-scheduled-experiments`: Contains chaos experiments that run on a recurring schedule.
* `/3-workflows`: Contains multis
* /test-results: Contains documentation of the results from running the experiments. Success criteria and observations are noted for each experiment.

## Prerequisites

1.  A running Kubernetes cluster.
2.  `kubectl` configured to connect to your cluster.
3.  [KubeDB Operator](https://kubedb.com/docs/latest/setup/) installed.
```
helm install kubedb oci://ghcr.io/appscode-charts/kubedb \
  --version v2026.2.26 \
  --namespace kubedb --create-namespace \
  --set-file global.license=/path/to/the/license.txt \
  --set global.featureGates.MSSQLServer=true \
  --wait --burst-limit=10000 --debug
```
4.  [Chaos Mesh](https://chaos-mesh.org/docs/quick-start/) installed.
```

helm install chaos-mesh chaos-mesh/chaos-mesh -n=chaos-mesh --set chaosDaemon.runtime=containerd --set chaosDaemon.socketPath=/run/containerd/containerd.sock --version 2.8.2

helm upgrade -i chaos-mesh chaos-mesh/chaos-mesh \
     -n chaos-mesh \
    --create-namespace \
    --set dashboard.create=true \
    --set dashboard.securityMode=false \
    --set chaosDaemon.runtime=containerd \
    --set chaosDaemon.socketPath=/run/containerd/containerd.sock \
    --set chaosDaemon.privileged=true

> Note: Make sure to set correct path to your container runtime socket and runtime in the above command. For ex: socketPath=/run/containerd/containerd.sock, or if in k3s, set chaosDaemon.socketPath=/run/k3s/containerd/containerd.sock.

kubectl get pods --namespace chaos-mesh -l app.kubernetes.io/instance=chaos-mesh
NAME                                        READY   STATUS    RESTARTS   AGE
chaos-controller-manager-7fc6b466df-bv8wk   1/1     Running   0          108s
chaos-controller-manager-7fc6b466df-gvnxr   1/1     Running   0          108s
chaos-controller-manager-7fc6b466df-sgmq4   1/1     Running   0          108s
chaos-daemon-7s52d                          1/1     Running   0          108s
chaos-dashboard-68d5c74d9c-hq6vt            1/1     Running   0          108s
chaos-dns-server-7666bdc646-h2vht           1/1     Running   0          108s
```

## Getting Started

### 1. Run the Setup Script

To create the entire directory structure and all experiment files, run the provided script:

```bash
chmod +x create-chaos-structure.sh
./create-chaos-structure.sh
```

### 2. Deploy the Target SQL Server Cluster

First, create the namespace and deploy the highly-available SQL Server cluster and the client pod for testing.

```bash
# Deploy the 3-node SQL Server cluster and client pod
kubectl apply -f setup/kubedb-sql-server-cluster.yaml
kubectl apply -f setup/client-pod.yaml

# Add a label to the client pod for DNSChaos targeting
kubectl label pod client-pod -n demo pod-name=client-pod
```

Wait for all pods to be in a `Running` state:

```bash
kubectl get pods -n demo -w
```

You can identify the primary and replica pods using their labels:

```bash
kubectl get pods -n demo \
        -l app.kubernetes.io/instance=sqlserver-ag-cluster \
        -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.labels.kubedb\.com/role}{"\n"}{end}'
sqlserver-ag-cluster-0	primary
sqlserver-ag-cluster-1	secondary
sqlserver-ag-cluster-2	secondary
```

### 3. Running the Experiments

Apply the YAML file for the experiment you want to run. Below is a summary of the available experiments.

#### Single Experiments (`1-single-experiments/`)

* **`pod-kill-primary.yaml`**: Kills the primary pod to test automatic failover.
```bash
kubectl apply -f 1-single-experiments/pod-kill-primary.yaml
```

* **`network-latency-primary-to-replicas.yaml`**: Adds 150ms latency between the primary and replicas to test replication lag.
```bash
kubectl apply -f 1-single-experiments/network-latency-primary-to-replicas.yaml
```
* **`network-partition-primary.yaml`**: Isolates the primary from replicas to test split-brain prevention.
* **`io-latency-primary.yaml`**: Simulates a slow disk on the primary pod.
* **`stress-cpu-primary.yaml`**: Injects high CPU load on the primary.
* **`stress-memory-replica.yaml`**: Injects high memory load on a replica to test OOMKilled recovery.
* **`dns-error-from-client.yaml`**: Simulates DNS resolution failures from the client pod to the database service.

#### Scheduled Experiments (`2-scheduled-experiments/`)

* **`schedule-nightly-replica-kill.yaml`**: Kills a random replica pod every night at 1 AM.
* **`schedule-weekend-cpu-stress.yaml`**: Runs a 30-minute CPU stress test on the primary every Saturday and Sunday at 4 AM.

#### Workflow Experiments (`3-workflows/`)

* **`workflow-degraded-failover.yaml`**: Makes the primary's storage slow and *then* kills the pod to test failover under duress.
* **`workflow-flaky-network-failover.yaml`**: Creates packet loss to one replica, then kills the primary to ensure the *healthy* replica is chosen for promotion.

