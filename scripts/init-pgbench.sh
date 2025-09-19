#!/bin/bash

# pgbench Database Initialization Script
# This script initializes the pgbench tables and data

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

echo "🚀 Initializing pgbench for database: $DB_NAME"
echo "📊 Scale factor: $SCALE_FACTOR (this creates $(($SCALE_FACTOR * 100000)) accounts)"

# Wait for PostgreSQL to be ready
echo "⏳ Waiting for PostgreSQL to be ready..."
until PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USERNAME -d $DB_NAME -c '\q' 2>/dev/null; do
  echo "PostgreSQL is unavailable - sleeping"
  sleep 2
done

echo "✅ PostgreSQL is ready!"

# Initialize pgbench tables
echo "🔧 Initializing pgbench tables with scale factor $SCALE_FACTOR..."
PGPASSWORD=$DB_PASSWORD pgbench -h $DB_HOST -p $DB_PORT -U $DB_USERNAME -d $DB_NAME -i -s $SCALE_FACTOR

echo "📈 pgbench tables created successfully!"
echo "📋 Tables created:"
echo "  - pgbench_accounts ($(($SCALE_FACTOR * 100000)) rows)"
echo "  - pgbench_branches ($SCALE_FACTOR rows)"
echo "  - pgbench_tellers ($(($SCALE_FACTOR * 10)) rows)"
echo "  - pgbench_history (0 rows initially)"

# Show table sizes
echo "📊 Table information:"
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USERNAME -d $DB_NAME -c "
SELECT 
    schemaname,
    tablename,
    attname,
    n_distinct,
    correlation
FROM pg_stats 
WHERE tablename LIKE 'pgbench_%'
ORDER BY tablename, attname;
"

echo "🎉 pgbench initialization completed!"