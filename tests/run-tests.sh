#!/bin/bash

# Chaos Test Execution Script for KubeDB PostgreSQL HA Cluster
# This script automates the execution of chaos engineering tests

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="demo"
CHAOS_NAMESPACE="chaos-mesh"
DB_INSTANCE="sqlserver-ag-cluster"
TEST_DIR="$(dirname "$0")"

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl not found. Please install kubectl."
        exit 1
    fi
    
    # Check if chaos-mesh namespace exists
    if ! kubectl get namespace $CHAOS_NAMESPACE &> /dev/null; then
        print_error "Chaos Mesh namespace not found. Please install Chaos Mesh."
        exit 1
    fi
    
    # Check if demo namespace exists
    if ! kubectl get namespace $NAMESPACE &> /dev/null; then
        print_warn "Demo namespace not found. Creating..."
        kubectl create namespace $NAMESPACE
    fi
    
    # Check if PostgreSQL cluster exists
    if ! kubectl get postgres $DB_INSTANCE -n $NAMESPACE &> /dev/null; then
        print_error "PostgreSQL cluster '$DB_INSTANCE' not found in namespace '$NAMESPACE'."
        print_info "Please deploy the cluster first: kubectl apply -f setup/kubedb-postgres.yaml"
        exit 1
    fi
    
    print_info "All prerequisites satisfied."
}

# Function to get current primary pod
get_primary_pod() {
    kubectl get pods -n $NAMESPACE -l "app.kubernetes.io/instance=$DB_INSTANCE,kubedb.com/role=primary" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo ""
}

# Function to display cluster status
show_cluster_status() {
    print_info "Current cluster status:"
    echo ""
    kubectl get pods -n $NAMESPACE -l "app.kubernetes.io/instance=$DB_INSTANCE" -o custom-columns=NAME:.metadata.name,ROLE:.metadata.labels.kubedb\\.com/role,STATUS:.status.phase,NODE:.spec.nodeName
    echo ""
}

# Function to test database connectivity
test_db_connectivity() {
    local primary_pod=$(get_primary_pod)
    if [ -z "$primary_pod" ]; then
        print_error "No primary pod found!"
        return 1
    fi
    
    print_info "Testing connectivity to primary pod: $primary_pod"
    if kubectl exec -n $NAMESPACE $primary_pod -- psql -U postgres -c "SELECT 1" &> /dev/null; then
        print_info "Database is accessible ✓"
        return 0
    else
        print_error "Database is not accessible ✗"
        return 1
    fi
}

# Function to run a single test
run_test() {
    local test_file=$1
    local test_name=$(basename "$test_file" .yaml)
    
    print_info "=================================================="
    print_info "Running test: $test_name"
    print_info "=================================================="
    
    # Show cluster status before test
    print_info "Cluster status BEFORE test:"
    show_cluster_status
    
    # Apply chaos experiment
    print_info "Applying chaos experiment..."
    kubectl apply -f "$test_file"
    
    # Wait for chaos to take effect
    print_info "Waiting for chaos to take effect (30 seconds)..."
    sleep 30
    
    # Show cluster status during test
    print_info "Cluster status DURING test:"
    show_cluster_status
    
    # Wait for test duration
    print_info "Waiting for test to complete..."
    sleep 120
    
    # Delete chaos experiment
    print_info "Cleaning up chaos experiment..."
    kubectl delete -f "$test_file"
    
    # Wait for recovery
    print_info "Waiting for cluster to recover (60 seconds)..."
    sleep 60
    
    # Show cluster status after test
    print_info "Cluster status AFTER test:"
    show_cluster_status
    
    # Test connectivity
    if test_db_connectivity; then
        print_info "Test $test_name: RECOVERED ✓"
    else
        print_warn "Test $test_name: NEEDS INVESTIGATION ⚠"
    fi
    
    echo ""
    print_info "Test $test_name completed."
    print_info "=================================================="
    echo ""
}

# Function to run all tests
run_all_tests() {
    print_info "Running all chaos tests..."
    
    local test_files=($(ls $TEST_DIR/*.yaml | sort))
    local total_tests=${#test_files[@]}
    local current=0
    
    for test_file in "${test_files[@]}"; do
        current=$((current + 1))
        print_info "Test $current of $total_tests"
        run_test "$test_file"
        
        # Wait between tests
        if [ $current -lt $total_tests ]; then
            print_info "Waiting 2 minutes before next test..."
            sleep 120
        fi
    done
    
    print_info "All tests completed!"
}

# Function to run specific test category
run_category_tests() {
    local category=$1
    print_info "Running $category tests..."
    
    local pattern=""
    case $category in
        pod)
            pattern="0[1-4]-*.yaml"
            ;;
        network)
            pattern="0[5-9]-*.yaml|10-*.yaml"
            ;;
        io)
            pattern="1[3-6]-*.yaml"
            ;;
        stress)
            pattern="1[8-9]-*.yaml"
            ;;
        *)
            print_error "Unknown category: $category"
            exit 1
            ;;
    esac
    
    local test_files=($(ls $TEST_DIR/*.yaml | grep -E "$pattern" | sort))
    
    for test_file in "${test_files[@]}"; do
        run_test "$test_file"
        sleep 120
    done
}

# Function to monitor cluster
monitor_cluster() {
    print_info "Monitoring cluster (press Ctrl+C to stop)..."
    watch -n 2 "kubectl get pods -n $NAMESPACE -l 'app.kubernetes.io/instance=$DB_INSTANCE' -o custom-columns=NAME:.metadata.name,ROLE:.metadata.labels.kubedb\\.com/role,STATUS:.status.phase,RESTARTS:.status.containerStatuses[0].restartCount"
}

# Function to cleanup all chaos experiments
cleanup_all() {
    print_info "Cleaning up all chaos experiments..."
    kubectl delete podchaos,networkchaos,iochaos,stresschaos,timechaos,dnschaos,nodechaos -n $CHAOS_NAMESPACE --all 2>/dev/null || true
    print_info "Cleanup completed."
}

# Function to show help
show_help() {
    cat << EOF
Chaos Test Execution Script for KubeDB PostgreSQL HA Cluster

Usage: $0 [command] [options]

Commands:
    check           Check prerequisites
    status          Show cluster status
    test <file>     Run a specific test file
    all             Run all tests sequentially
    pod             Run all pod-level chaos tests
    network         Run all network chaos tests
    io              Run all I/O chaos tests
    stress          Run all stress tests
    monitor         Monitor cluster in real-time
    cleanup         Remove all chaos experiments
    help            Show this help message

Examples:
    $0 check                           # Check prerequisites
    $0 status                          # Show cluster status
    $0 test tests/02-pod-kill.yaml     # Run specific test
    $0 all                             # Run all tests
    $0 pod                             # Run pod chaos tests
    $0 monitor                         # Monitor cluster
    $0 cleanup                         # Clean up experiments

EOF
}

# Main script logic
main() {
    case "${1:-help}" in
        check)
            check_prerequisites
            ;;
        status)
            check_prerequisites
            show_cluster_status
            ;;
        test)
            if [ -z "$2" ]; then
                print_error "Please specify a test file."
                exit 1
            fi
            check_prerequisites
            run_test "$2"
            ;;
        all)
            check_prerequisites
            run_all_tests
            ;;
        pod|network|io|stress)
            check_prerequisites
            run_category_tests "$1"
            ;;
        monitor)
            monitor_cluster
            ;;
        cleanup)
            cleanup_all
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
