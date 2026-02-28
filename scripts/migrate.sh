#!/bin/bash

# Database Migration Script
# Author: Ian Acosta
# Description: Run Supabase database migrations

set -e

echo "🗄️  Starting database migration..."

# Load environment variables
if [ -f .env ]; then
  export $(cat .env | grep -v '^#' | xargs)
fi

# Check if Supabase CLI is installed
if ! command -v supabase &> /dev/null; then
  echo "❌ Supabase CLI not found. Installing..."
  npm install -g supabase
fi

# Run migrations
echo "📤 Pushing migrations to Supabase..."
supabase db push --db-url "$SUPABASE_URL"

echo "✅ Database migration completed successfully!"
