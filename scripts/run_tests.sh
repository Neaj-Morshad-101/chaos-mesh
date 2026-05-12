#!/bin/bash

set -e

TESTS_DIR="$(dirname "$0")/../tests"

if [ ! -d "$TESTS_DIR" ]; then
    echo "Error: tests directory not found"
    exit 1
fi

mapfile -t test_files < <(find "$TESTS_DIR" -name "*.yaml" -type f | sort)

if [ ${#test_files[@]} -eq 0 ]; then
    echo "Error: No test files found in $TESTS_DIR"
    exit 1
fi

echo "=========================================="
echo "Starting Chaos Tests Runner"
echo "=========================================="
echo "Tests directory: $TESTS_DIR"
echo "Total tests: ${#test_files[@]}"
echo ""
initial="sleep"


current_test=0
for test_file in "${test_files[@]}"; do
    current_test=$((current_test + 1))
    test_name=$(basename "$test_file")

    echo ""
    echo "=========================================="
    echo "Test $current_test/${#test_files[@]}: $test_name"
    echo "=========================================="

    kubectl apply -f "$test_file"
    if [[ $initial == "sleep" ]];then
      sleep 70
      initial="no"
    fi

    max_attempts=30
    attempt=0

    while [ $attempt -lt $max_attempts ]; do
        db_info=$(kubectl get ms -n demo -ojsonpath='{range .items[*]}{.metadata.name}:{.status.phase}{"\n"}{end}' 2>/dev/null)

        if [ -n "$db_info" ]; then
            all_ready=true
            while IFS=': ' read -r db_name db_phase; do
                if [ "$db_phase" != "Ready" ]; then
                    all_ready=false
                fi
                echo "  $db_name: $db_phase"
            done <<< "$db_info"

            if $all_ready; then
                echo ""
                echo "[$test_name] All databases Ready!"
                initial="sleep"
                break
            fi
        else
            echo "  No databases found"
            break
        fi

        attempt=$((attempt + 1))
        sleep 10
    done
    kubectl get pods -n demo --show-labels | grep primary
    if [ $attempt -ge $max_attempts ]; then
        echo ""
        echo "[$test_name] Warning: Max attempts reached"
    fi
done

echo ""
echo "=========================================="
echo "All chaos tests applied successfully!"
echo "=========================================="
echo "Total tests applied: ${#test_files[@]}"