#!/bin/bash

# Database migration script
# Usage: ./scripts/migrate.sh [up|down|create migration_name]

set -e

MIGRATION_DIR="database/migrations"
MIGRATION_FILE=""

if [ "$1" == "create" ]; then
    if [ -z "$2" ]; then
        echo "Error: Migration name required"
        echo "Usage: ./scripts/migrate.sh create migration_name"
        exit 1
    fi
    
    TIMESTAMP=$(date +%Y%m%d%H%M%S)
    MIGRATION_FILE="${MIGRATION_DIR}/${TIMESTAMP}_${2}.sql"
    
    cat > "$MIGRATION_FILE" << EOF
-- Migration: $2
-- Created: $(date)

-- Up migration
BEGIN;

-- Add your migration SQL here

COMMIT;

-- Down migration (rollback)
-- BEGIN;
-- Add your rollback SQL here
-- COMMIT;
EOF
    
    echo "Migration file created: $MIGRATION_FILE"
    exit 0
fi

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Connect to database and run migrations
PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d $POSTGRES_DB << EOF
-- Run migrations from $MIGRATION_DIR
\i $MIGRATION_DIR/001_initial_schema.sql
EOF

echo "Migrations completed"


