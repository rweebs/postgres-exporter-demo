#!/bin/bash

# pgbench Load Testing Script
# This script runs various workloads to test the PostgreSQL monitoring dashboard

set -e

# Configuration
DB_HOST=localhost
DB_PORT=5433
DB_NAME=monitoring
DB_USERNAME=postgres
DB_PASSWORD=secret_password
SCALE_FACTOR=10
CLIENTS=10
THREADS=4
DURATION=60
GRAFANA_PORT=3000
PROMETHEUS_PORT=9090

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo_color() {
    echo -e "${1}${2}${NC}"
}

run_test() {
    local test_name=$1
    local description=$2
    local extra_args=$3
    
    echo_color $BLUE "🚀 Running test: $test_name"
    echo_color $YELLOW "📝 Description: $description"
    echo_color $YELLOW "⚙️  Parameters: $CLIENTS clients, $THREADS threads, ${DURATION}s duration"
    echo_color $YELLOW "🔧 Extra args: $extra_args"
    echo ""
    
    PGPASSWORD=$DB_PASSWORD pgbench \
        -h $DB_HOST \
        -p $DB_PORT \
        -U $DB_USERNAME \
        -d $DB_NAME \
        -c $CLIENTS \
        -j $THREADS \
        -T $DURATION \
        $extra_args
    
    echo_color $GREEN "✅ Test completed: $test_name"
    echo "===========================================" 
    sleep 5
}

echo_color $GREEN "🎯 Starting pgbench load testing suite"
echo_color $YELLOW "🔗 Database: $DB_HOST:$DB_PORT/$DB_NAME"
echo_color $YELLOW "👤 User: $DB_USERNAME"
echo ""

# Test 1: Standard TPC-B workload (read-write)
run_test "Standard TPC-B" \
    "Standard pgbench workload with read/write transactions" \
    "--log --aggregate-interval=5"

# Test 2: Read-only workload
run_test "Read-Only Workload" \
    "Select-only transactions to test read performance" \
    "-S --log --aggregate-interval=5"

# Test 3: High connection count
run_test "High Connection Load" \
    "Test with many concurrent connections" \
    "-c 50 -j 8 --log --aggregate-interval=5"

# Test 4: Custom workload with prepared statements
run_test "Prepared Statements" \
    "Using prepared statements for better performance" \
    "-M prepared --log --aggregate-interval=5"

# Test 5: Simple update workload
run_test "Update Heavy" \
    "Update-heavy workload to stress write operations" \
    "-N --log --aggregate-interval=5"

# Test 6: Long duration stress test
echo_color $BLUE "🔥 Running extended stress test (5 minutes)"
run_test "Extended Stress Test" \
    "Long-running test to observe sustained performance" \
    "-T 300 --log --aggregate-interval=10"

echo_color $GREEN "🎉 All pgbench tests completed!"
echo_color $YELLOW "📊 Check your Grafana dashboard to see the metrics!"
echo_color $YELLOW "🔗 Grafana should be available at: http://localhost:${GRAFANA_PORT:-3000}"
echo_color $YELLOW "🔗 Prometheus should be available at: http://localhost:${PROMETHEUS_PORT:-9090}"