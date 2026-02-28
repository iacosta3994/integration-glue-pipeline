#!/bin/bash

# Integration Glue Pipeline Deployment Script
# Author: Ian Acosta
# Description: Automated deployment script for production

set -e

echo "🚀 Starting deployment..."

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT=${1:-production}
BRANCH=${2:-main}

echo -e "${YELLOW}Environment: $ENVIRONMENT${NC}"
echo -e "${YELLOW}Branch: $BRANCH${NC}"

# Step 1: Pull latest changes
echo "📥 Pulling latest changes..."
git checkout $BRANCH
git pull origin $BRANCH

# Step 2: Install dependencies
echo "📦 Installing dependencies..."
npm ci --production

# Step 3: Run tests
echo "🧪 Running tests..."
npm test || echo -e "${YELLOW}Warning: Tests failed${NC}"

# Step 4: Build Docker image
echo "🐳 Building Docker image..."
docker build -f docker/Dockerfile.prod -t integration-glue-pipeline:latest .

# Step 5: Stop existing containers
echo "🛑 Stopping existing containers..."
docker-compose down || true

# Step 6: Start new containers
echo "▶️  Starting new containers..."
docker-compose up -d

# Step 7: Wait for health check
echo "🏥 Waiting for health check..."
sleep 10

HEALTH_STATUS=$(curl -s http://localhost:3000/health | grep -o '"status":"healthy"' || echo "")

if [ -z "$HEALTH_STATUS" ]; then
  echo -e "${RED}❌ Deployment failed: Health check unsuccessful${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo "🌐 Application is running at http://localhost:3000"
