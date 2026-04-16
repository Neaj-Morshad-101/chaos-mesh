#!/bin/bash

NAMESPACE="demo"
POD_PREFIX="sqlserver-ag-cluster"
CONTAINER="postgres"
SCRIPT_FILE="a.sh"

echo "Starting to copy and make executable: $SCRIPT_FILE"
echo "=================================================="

for i in 0 1 2; do
    POD_NAME="$POD_PREFIX-$i"
    
    echo
    echo "Processing pod: $POD_NAME"
    echo "------------------------"
    
    # Check if pod exists
    if ! kubectl get pod -n "$NAMESPACE" "$POD_NAME" &> /dev/null; then
        echo "❌ Pod $POD_NAME not found. Skipping..."
        continue
    fi
    
    # Copy the script to the pod
    echo "📤 Copying $SCRIPT_FILE to $POD_NAME:/var/pv/"
    if kubectl cp "$SCRIPT_FILE" "$NAMESPACE/$POD_NAME:/var/pv/$SCRIPT_FILE" -c "$CONTAINER"; then
        echo "✅ Copy successful"
        
        # Make the script executable
        echo "🔧 Setting executable permissions..."
        if kubectl exec -it -n "$NAMESPACE" "$POD_NAME" -c "$CONTAINER" -- chmod +x "/var/pv/$SCRIPT_FILE"; then
            echo "✅ Permissions set successfully"
            
            # Verify the file
            echo "🔍 Verifying file..."
            kubectl exec -it -n "$NAMESPACE" "$POD_NAME" -c "$CONTAINER" -- ls -la "/var/pv/$SCRIPT_FILE"
        else
            echo "❌ Failed to set permissions"
        fi
    else
        echo "❌ Copy failed"
    fi
done

echo
echo "=================================================="
echo "Operation completed for all pods"
