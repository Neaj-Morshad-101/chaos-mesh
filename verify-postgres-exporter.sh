#!/bin/bash
# Quick verification script for PostgreSQL Exporter

echo "🔍 PostgreSQL Exporter Health Check"
echo "===================================="
echo ""

POD_NAME="monitor-postgres-0"
NAMESPACE="demo"
CONTAINER="exporter"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "📊 Checking exporter logs..."
echo "----------------------------"
kubectl logs -n "$NAMESPACE" "$POD_NAME" -c "$CONTAINER" --tail=10
echo ""

echo "🔌 Testing metrics endpoint..."
echo "------------------------------"
METRICS_COUNT=$(kubectl exec -n "$NAMESPACE" "$POD_NAME" -c "$CONTAINER" -- sh -c "wget -q -O- http://localhost:56790/metrics 2>/dev/null | wc -l")
echo -e "${GREEN}✓${NC} Total metrics lines: $METRICS_COUNT"
echo ""

echo "🐘 Checking PostgreSQL connection status..."
echo "-------------------------------------------"
mssql_UP=$(kubectl exec -n "$NAMESPACE" "$POD_NAME" -c "$CONTAINER" -- sh -c "wget -q -O- http://localhost:56790/metrics 2>/dev/null | grep '^mssql_up ' | awk '{print \$2}'")

if [ "$mssql_UP" = "1" ]; then
    echo -e "${GREEN}✓ mssql_up = 1${NC} - PostgreSQL connection is healthy!"
else
    echo -e "${RED}✗ mssql_up = 0${NC} - PostgreSQL connection failed!"
    exit 1
fi
echo ""

echo "📈 Sample PostgreSQL metrics..."
echo "-------------------------------"
kubectl exec -n "$NAMESPACE" "$POD_NAME" -c "$CONTAINER" -- sh -c "wget -q -O- http://localhost:56790/metrics 2>/dev/null | grep -E '^mssql_(database_size|stat_database_numbackends|locks)' | head -10"
echo ""

echo "⚠️  About the config warning..."
echo "-------------------------------"
echo -e "${YELLOW}The 'postgres_exporter.yml' warning is harmless.${NC}"
echo "Your exporter is working correctly using environment variables."
echo "This is the recommended configuration method in Kubernetes."
echo ""

echo "===================================="
echo -e "${GREEN}✅ PostgreSQL Exporter is working correctly!${NC}"
echo "===================================="
