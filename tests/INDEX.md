# Chaos Engineering Tests for KubeDB PostgreSQL - Complete Test Suite

## 📋 Overview

This directory contains a comprehensive chaos engineering test suite with **19 different chaos scenarios** designed to validate the resilience, high availability, and disaster recovery capabilities of KubeDB-managed PostgreSQL clusters.

## 📁 Directory Structure

```
tests/
├── README.md                      # Comprehensive guide with detailed explanations
├── TEST-SUMMARY.md               # Executive summary with statistics and matrix
├── QUICK-REFERENCE.md            # Quick commands and troubleshooting
├── run-tests.sh                  # Automated test execution script (executable)
│
├── 01-pod-failure.yaml           # Pod Failure Test
├── 02-pod-kill.yaml              # Pod Kill Test
├── 03-pod-oom.yaml               # Out of Memory Test
├── 04-kill-postgres-process.yaml # Process Kill Test
│
├── 05-network-partition.yaml     # Network Partition Test
├── 06-network-bandwidth.yaml     # Bandwidth Limitation Test
├── 07-network-delay.yaml         # Network Latency Test
├── 08-network-loss.yaml          # Packet Loss Test
├── 09-network-duplicate.yaml     # Packet Duplication Test
├── 10-network-corrupt.yaml       # Packet Corruption Test
│
├── 11-time-offset.yaml           # Time Skew Test
├── 12-dns-error.yaml             # DNS Failure Test
│
├── 13-io-latency.yaml            # I/O Latency Test
├── 14-io-fault.yaml              # I/O Fault Test
├── 15-io-attr-override.yaml      # File Permission Test
├── 16-io-mistake.yaml            # Data Corruption Test
│
├── 17-node-reboot.yaml           # Node Reboot Test
├── 18-stress-cpu-primary.yaml    # CPU Stress Test
└── 19-stress-memory-replica.yaml # Memory Stress Test
```

## 🚀 Quick Start

### 1. Prerequisites
```bash
# Navigate to tests directory
cd tests

# Check prerequisites
./run-tests.sh check
```

### 2. Run Your First Test
```bash
# Pod kill test (expected to pass)
./run-tests.sh test 02-pod-kill.yaml
```

### 3. Monitor the Cluster
```bash
# Open in another terminal
./run-tests.sh monitor
```

## 📚 Documentation Files

| File | Purpose | Use When |
|------|---------|----------|
| **README.md** | Full documentation | Setting up, understanding tests |
| **TEST-SUMMARY.md** | Executive summary | Reporting, planning |
| **QUICK-REFERENCE.md** | Command cheatsheet | Running tests, troubleshooting |
| **run-tests.sh** | Automation script | Executing tests |

## 🎯 Test Categories

### 1️⃣ Pod Chaos Tests (4 tests)
Tests pod-level failures and recovery mechanisms.
- `01-pod-failure.yaml` - Extended pod failure (5 min)
- `02-pod-kill.yaml` - Immediate pod termination ✓
- `03-pod-oom.yaml` - Out of memory condition
- `04-kill-postgres-process.yaml` - Process crash

**Run all**: `./run-tests.sh pod`

### 2️⃣ Network Chaos Tests (6 tests)
Tests network-related issues and replication under network stress.
- `05-network-partition.yaml` - Split-brain scenarios
- `06-network-bandwidth.yaml` - Bandwidth throttling
- `07-network-delay.yaml` - High latency
- `08-network-loss.yaml` - Complete packet loss ✓
- `09-network-duplicate.yaml` - Duplicate packets ✓
- `10-network-corrupt.yaml` - Corrupted packets

**Run all**: `./run-tests.sh network`

### 3️⃣ I/O Chaos Tests (4 tests)
Tests storage-related failures and data integrity.
- `13-io-latency.yaml` - Storage performance degradation
- `14-io-fault.yaml` - I/O errors
- `15-io-attr-override.yaml` - Permission issues
- `16-io-mistake.yaml` - Data corruption

**Run all**: `./run-tests.sh io`

### 4️⃣ Resource Stress Tests (2 tests)
Tests system resource pressure handling.
- `18-stress-cpu-primary.yaml` - CPU stress ✓
- `19-stress-memory-replica.yaml` - Memory stress ✓

**Run all**: `./run-tests.sh stress`

### 5️⃣ System Chaos Tests (3 tests)
Tests system-level failures.
- `11-time-offset.yaml` - Time drift
- `12-dns-error.yaml` - DNS failures ✓
- `17-node-reboot.yaml` - Node failures

## 🎮 Usage Examples

### Run Specific Test
```bash
./run-tests.sh test 02-pod-kill.yaml
```

### Run Category
```bash
./run-tests.sh network    # All network tests
./run-tests.sh pod        # All pod tests
./run-tests.sh io         # All I/O tests
./run-tests.sh stress     # All stress tests
```

### Run All Tests
```bash
./run-tests.sh all        # Sequential execution (~4 hours)
```

### Manual Test Execution
```bash
# Apply test
kubectl apply -f 02-pod-kill.yaml

# Monitor
watch kubectl get pods -n demo

# Cleanup
kubectl delete -f 02-pod-kill.yaml
```

## 📊 Expected Results

| Result | Count | Percentage |
|--------|-------|------------|
| ✅ Pass | 6 | 31.6% |
| ❌ Fail | 13 | 68.4% |

**Note**: "Fail" means the test successfully demonstrates a failure scenario that requires intervention or has expected degradation. These are valuable for understanding system limits.

## 🔍 Key Features

### ✨ Comprehensive Coverage
- Pod lifecycle management
- Network reliability
- Storage resilience
- Resource management
- System-level failures

### 🛠️ Easy to Use
- Simple shell script interface
- Detailed documentation
- Quick reference guide
- Automated test execution

### 📈 Production-Ready
- Based on real-world scenarios
- Follows KubeDB best practices
- Industry-standard chaos patterns
- Comprehensive validation

### 🔒 Safety First
- Non-destructive by default
- Easy cleanup procedures
- Clear rollback steps
- Monitoring guidelines

## 🎓 Learning Path

### Beginners
1. Read `README.md` for full context
2. Run `./run-tests.sh check` to verify setup
3. Start with `02-pod-kill.yaml` (simple, passes)
4. Monitor using `./run-tests.sh monitor`
5. Review `QUICK-REFERENCE.md` for commands

### Intermediate
1. Run category tests (`./run-tests.sh pod`)
2. Understand failover behavior
3. Experiment with timing and parameters
4. Monitor replication and recovery

### Advanced
1. Run full test suite (`./run-tests.sh all`)
2. Analyze failure patterns
3. Customize tests for your environment
4. Integrate with CI/CD pipeline

## 📖 Related Documentation

### In This Repository
- `/postgres/failure-and-disaster-recovery/` - Failover concepts
- `/postgres/clustering/` - HA cluster setup
- `/setup/kubedb-postgres.yaml` - PostgreSQL configuration

### External Resources
- [KubeDB Documentation](https://kubedb.com/docs/latest/guides/postgres/)
- [Chaos Mesh Documentation](https://chaos-mesh.org/docs/)
- [PostgreSQL HA Guide](https://www.postgresql.org/docs/current/high-availability.html)

## 🔧 Configuration

### Default Settings
- **Namespace**: `demo`
- **Cluster Name**: `sqlserver-ag-cluster`
- **Chaos Namespace**: `chaos-mesh`
- **Test Duration**: Varies (30s - 10m)
- **Recovery Wait**: 60-120s between tests

### Customization
Edit individual YAML files to adjust:
- Target namespaces
- Label selectors
- Duration values
- Intensity parameters

## ⚠️ Important Notes

### Before Running Tests
1. ✅ Run in **non-production** environment
2. ✅ **Backup** your data
3. ✅ Allocate **3-4 hours** for full suite
4. ✅ Set up **monitoring**
5. ✅ Notify your **team**

### During Tests
1. 👀 **Watch** pod status
2. 📝 **Document** observations
3. 🔍 **Monitor** logs
4. ⏱️ **Track** failover timing

### After Tests
1. ✔️ **Verify** data integrity
2. 🧹 **Cleanup** chaos experiments
3. 📊 **Analyze** results
4. 📚 **Update** documentation

## 🐛 Troubleshooting

### Common Issues

| Problem | Solution |
|---------|----------|
| Script won't run | `chmod +x run-tests.sh` |
| Test not applying | Check Chaos Mesh installation |
| Cluster not recovering | Review operator logs |
| Permission denied | Check RBAC permissions |

**Full troubleshooting**: See `QUICK-REFERENCE.md`

## 🤝 Contributing

To add new tests:
1. Create YAML file with sequential number
2. Update `README.md` with test details
3. Add to `TEST-SUMMARY.md` matrix
4. Update `QUICK-REFERENCE.md`
5. Test thoroughly
6. Submit PR

## 📞 Support

- **Documentation**: Read `README.md`
- **Quick Help**: Check `QUICK-REFERENCE.md`
- **Issues**: Review `TEST-SUMMARY.md` for known issues

## 📝 License

Part of the KubeDB PostgreSQL chaos engineering test suite.

---

## 🎯 Next Steps

1. **Read Full Documentation**: Open `README.md`
2. **Check Prerequisites**: Run `./run-tests.sh check`
3. **Start Testing**: Try `./run-tests.sh test 02-pod-kill.yaml`
4. **Monitor Results**: Use `./run-tests.sh monitor`
5. **Review Summary**: Check `TEST-SUMMARY.md`

**Happy Chaos Testing! 🚀**
