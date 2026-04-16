#!/bin/bash
# Quick test script to verify all fixed tests work

set -e

echo "🧪 Testing All Fixed Chaos Tests"
echo "================================="
echo ""

TESTS_DIR="/home/saurov/go/src/github.com/souravbiswassanto/chaos-mesh/tests"
FAILED=0
PASSED=0

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

test_file() {
    local file=$1
    local name=$(basename $file .yaml)
    
    echo -n "Testing $name ... "
    
    if kubectl apply -f "$file" &> /dev/null; then
        echo -e "${GREEN}✓ PASS${NC}"
        PASSED=$((PASSED + 1))
        # Clean up
        kubectl delete -f "$file" &> /dev/null || true
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        FAILED=$((FAILED + 1))
        kubectl apply -f "$file" 2>&1 | head -3
        return 1
    fi
}

echo "🔍 Cleaning up existing chaos experiments..."
kubectl delete podchaos,networkchaos,iochaos,stresschaos,timechaos,dnschaos -n chaos-mesh --all &> /dev/null || true
echo ""

echo "📋 Testing Previously Fixed Files:"
echo "-----------------------------------"

# Test fixed files
test_file "$TESTS_DIR/01-pod-failure.yaml"
test_file "$TESTS_DIR/03-pod-oom.yaml"
test_file "$TESTS_DIR/06-network-bandwidth.yaml"
test_file "$TESTS_DIR/07-network-delay.yaml"
test_file "$TESTS_DIR/08-network-loss.yaml"
test_file "$TESTS_DIR/09-network-duplicate.yaml"
test_file "$TESTS_DIR/10-network-corrupt.yaml"
test_file "$TESTS_DIR/13-io-latency.yaml"
test_file "$TESTS_DIR/14-io-fault.yaml"
test_file "$TESTS_DIR/15-io-attr-override.yaml"
test_file "$TESTS_DIR/16-io-mistake.yaml"
test_file "$TESTS_DIR/17-node-reboot.yaml"
test_file "$TESTS_DIR/19-stress-memory-replica.yaml"

echo ""
echo "📋 Testing Already Working Files:"
echo "----------------------------------"

test_file "$TESTS_DIR/02-pod-kill.yaml"
test_file "$TESTS_DIR/04-kill-postgres-process.yaml"
test_file "$TESTS_DIR/05-network-partition.yaml"
test_file "$TESTS_DIR/11-time-offset.yaml"
test_file "$TESTS_DIR/12-dns-error.yaml"
test_file "$TESTS_DIR/18-stress-cpu-primary.yaml"

echo ""
echo "================================="
echo "📊 Test Results Summary"
echo "================================="
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo "Total:  $((PASSED + FAILED))"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}⚠️  Some tests failed. Check output above.${NC}"
    exit 1
fi
