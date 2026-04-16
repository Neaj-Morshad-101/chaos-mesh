# 🎯 START HERE - Chaos Testing Guide

Welcome! This is your entry point for chaos engineering tests on KubeDB PostgreSQL.

## 📦 What's Inside?

You now have a complete chaos testing suite with:
- ✅ **19 chaos test scenarios** covering all failure modes
- ✅ **Automated test runner** script
- ✅ **Comprehensive documentation** (4 guides)
- ✅ **Validation checklist** for thorough testing

## 🚀 Quick Start (3 Steps)

### Step 1: Verify Prerequisites
```bash
cd tests
./run-tests.sh check
```

### Step 2: Run Your First Test
```bash
./run-tests.sh test 02-pod-kill.yaml
```

### Step 3: View Results
```bash
./run-tests.sh status
```

That's it! 🎉

## 📚 Documentation Guide

| File | When to Use |
|------|-------------|
| **📋 INDEX.md** | Start here for overview and navigation |
| **📖 README.md** | Full setup and detailed explanations |
| **📊 TEST-SUMMARY.md** | Test statistics and matrix |
| **⚡ QUICK-REFERENCE.md** | Quick commands and troubleshooting |
| **✅ VALIDATION-CHECKLIST.md** | Step-by-step test validation |

## 🎮 Common Commands

```bash
# Check if everything is ready
./run-tests.sh check

# See cluster status
./run-tests.sh status

# Run a single test
./run-tests.sh test 02-pod-kill.yaml

# Run all pod chaos tests
./run-tests.sh pod

# Run all network tests
./run-tests.sh network

# Monitor cluster real-time
./run-tests.sh monitor

# Clean up all experiments
./run-tests.sh cleanup

# See all options
./run-tests.sh help
```

## 📋 Test Files (19 Total)

### ✅ Tests Expected to Pass (6)
- `02-pod-kill.yaml` - Pod termination and failover
- `08-network-loss.yaml` - 100% packet loss handling
- `09-network-duplicate.yaml` - Duplicate packet handling
- `12-dns-error.yaml` - DNS failure resilience
- `18-stress-cpu-primary.yaml` - CPU stress tolerance
- `19-stress-memory-replica.yaml` - Memory stress tolerance

### ⚠️ Tests Expected to Show Issues (13)
- Pod: `01`, `03`, `04` - Various pod failures
- Network: `05`, `06`, `07`, `10` - Network degradation
- System: `11`, `17` - Time drift, node failures
- I/O: `13`, `14`, `15`, `16` - Storage issues

## 🎯 Recommended Learning Path

### 🌱 Beginner (30 minutes)
1. Read `INDEX.md` for overview
2. Run `./run-tests.sh check`
3. Try `./run-tests.sh test 02-pod-kill.yaml`
4. Watch with `./run-tests.sh monitor`

### 🌿 Intermediate (2 hours)
1. Read `README.md` for full context
2. Run `./run-tests.sh pod` (all pod tests)
3. Review `QUICK-REFERENCE.md` for commands
4. Document findings using `VALIDATION-CHECKLIST.md`

### 🌳 Advanced (4+ hours)
1. Run `./run-tests.sh all` (complete suite)
2. Analyze failure patterns
3. Customize tests for your needs
4. Review `TEST-SUMMARY.md` for reporting

## ⚡ Quick Test Examples

### Example 1: Test Pod Failover (2 minutes)
```bash
# Apply test
kubectl apply -f 02-pod-kill.yaml

# Watch pods (in another terminal)
watch kubectl get pods -n demo

# See the failover happen (2-10 seconds!)
# Then cleanup
kubectl delete -f 02-pod-kill.yaml
```

### Example 2: Test Network Issues (5 minutes)
```bash
./run-tests.sh test 08-network-loss.yaml
# Observe how cluster handles 100% packet loss
```

### Example 3: Run All Tests (3-4 hours)
```bash
./run-tests.sh all
# Grab coffee, monitor progress, document results
```

## 🔍 What to Monitor

During any test, watch these:
1. **Pod Status**: `kubectl get pods -n demo -w`
2. **Pod Roles**: Which pod is primary vs secondary
3. **Failover Time**: How fast does secondary become primary?
4. **Data Integrity**: Is your data safe?
5. **Logs**: What's happening in mssql-coordinator?

## 🎓 Understanding Test Results

### ✅ "Pass" Means:
- Cluster recovered automatically
- No data loss
- Failover happened (if expected)
- System returned to healthy state

### ❌ "Fail" Means:
- This test exposed a vulnerability
- You learned where improvements are needed
- Now you know system limits
- Great for capacity planning!

**Remember**: Even "failing" tests provide valuable insights! 💡

## 🚨 Important Safety Notes

### ⚠️ Before You Start
- [ ] This is NOT production (right?)
- [ ] You have recent backups
- [ ] Team knows you're testing
- [ ] You have 3-4 hours for full suite
- [ ] Monitoring is ready

### 🛡️ If Something Goes Wrong
```bash
# Emergency cleanup
./run-tests.sh cleanup

# Check cluster
kubectl get postgres -n demo
kubectl get pods -n demo

# Check logs
kubectl logs -n kubedb -l app.kubernetes.io/name=kubedb-ops-manager

# Still stuck? Check QUICK-REFERENCE.md troubleshooting section
```

## 📊 Test Statistics at a Glance

```
Total Tests:        19
Expected Pass:       6 (31.6%)
Expected Issues:    13 (68.4%)

Categories:
├── Pod Chaos:       4 tests
├── Network Chaos:   6 tests  
├── I/O Chaos:       4 tests
├── System Chaos:    3 tests
└── Stress Tests:    2 tests
```

## 🎯 Your First Mission

Ready to start? Here's your first mission:

1. **Verify**: `./run-tests.sh check` ✓
2. **Test**: `./run-tests.sh test 02-pod-kill.yaml` ✓
3. **Observe**: Watch the failover magic! ✨
4. **Learn**: Read what happened in logs ✓

Expected time: **5 minutes**
Expected result: **Mind = Blown** 🤯

## 📞 Need Help?

- **Quick commands**: `QUICK-REFERENCE.md`
- **Full guide**: `README.md`
- **Test details**: `TEST-SUMMARY.md`
- **Validation steps**: `VALIDATION-CHECKLIST.md`
- **Script help**: `./run-tests.sh help`

## 🎉 You're Ready!

Everything is set up. Time to break things and learn! 🚀

**Pro Tip**: Start with simple tests, monitor carefully, and document everything.

---

**Next Step**: Open `INDEX.md` for complete navigation, or just run your first test now! 

```bash
./run-tests.sh test 02-pod-kill.yaml
```

Good luck and happy chaos testing! 💪
