#!/bin/bash

# Setup Validation Script
# Author: Ian Acosta
# Description: Validate all credentials and services are configured correctly

set -e

echo "✅ Integration Glue Pipeline - Setup Validation"
echo "============================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Load environment variables
if [ ! -f .env ]; then
  echo -e "${RED}❌ .env file not found!${NC}"
  echo "   Run: cp .env.example .env"
  echo "   Then fill in your credentials."
  exit 1
fi

echo -e "${GREEN}✅ Found .env file${NC}"
set -a
source .env
set +a
echo ""

# Helper functions
test_pass() {
  echo -e "${GREEN}✅ $1${NC}"
  PASSED=$((PASSED + 1))
}

test_fail() {
  echo -e "${RED}❌ $1${NC}"
  if [ -n "$2" ]; then
    echo -e "   ${YELLOW}Fix: $2${NC}"
  fi
  FAILED=$((FAILED + 1))
}

test_warn() {
  echo -e "${YELLOW}⚠️  $1${NC}"
  if [ -n "$2" ]; then
    echo -e "   ${BLUE}Note: $2${NC}"
  fi
  WARNINGS=$((WARNINGS + 1))
}

# ==========================================
# 1. CHECK REQUIRED TOOLS
# ==========================================

echo -e "${BLUE}[1/6] Checking Required Tools...${NC}"
echo ""

if command -v node &> /dev/null; then
  NODE_VERSION=$(node --version)
  test_pass "Node.js installed: $NODE_VERSION"
else
  test_fail "Node.js not installed" "Install from https://nodejs.org"
fi

if command -v npm &> /dev/null; then
  NPM_VERSION=$(npm --version)
  test_pass "npm installed: $NPM_VERSION"
else
  test_fail "npm not installed" "Install Node.js (includes npm)"
fi

if command -v docker &> /dev/null; then
  DOCKER_VERSION=$(docker --version | cut -d ' ' -f3 | tr -d ',')
  test_pass "Docker installed: $DOCKER_VERSION"
else
  test_warn "Docker not installed" "Optional but recommended"
fi

if command -v git &> /dev/null; then
  GIT_VERSION=$(git --version | cut -d ' ' -f3)
  test_pass "Git installed: $GIT_VERSION"
else
  test_fail "Git not installed" "Install from https://git-scm.com"
fi

echo ""

# ==========================================
# 2. VALIDATE ENVIRONMENT VARIABLES
# ==========================================

echo -e "${BLUE}[2/6] Validating Environment Variables...${NC}"
echo ""

# Check if required variables are set
if [ -n "$SUPABASE_URL" ]; then
  if [[ $SUPABASE_URL =~ ^https://.*\.supabase\.co$ ]]; then
    test_pass "SUPABASE_URL is set and valid"
  else
    test_fail "SUPABASE_URL format is incorrect" "Should be https://xxxxx.supabase.co"
  fi
else
  test_fail "SUPABASE_URL not set" "Add to .env file"
fi

if [ -n "$SUPABASE_KEY" ]; then
  if [[ $SUPABASE_KEY == eyJ* ]]; then
    test_pass "SUPABASE_KEY is set (anon key)"
  else
    test_warn "SUPABASE_KEY might be incorrect" "Should start with 'eyJ'"
  fi
else
  test_fail "SUPABASE_KEY not set" "Add to .env file"
fi

if [ -n "$NOTION_TOKEN" ]; then
  if [[ $NOTION_TOKEN == secret_* ]]; then
    test_pass "NOTION_TOKEN is set"
  else
    test_warn "NOTION_TOKEN might be incorrect" "Should start with 'secret_'"
  fi
else
  test_fail "NOTION_TOKEN not set" "Add to .env file"
fi

if [ -n "$NOTION_DATABASE_ID" ]; then
  if [[ ${#NOTION_DATABASE_ID} -eq 32 ]]; then
    test_pass "NOTION_DATABASE_ID is set (correct length)"
  else
    test_warn "NOTION_DATABASE_ID might be incorrect" "Should be 32 characters"
  fi
else
  test_fail "NOTION_DATABASE_ID not set" "Add to .env file"
fi

if [ -n "$NETLIFY_AUTH_TOKEN" ]; then
  test_pass "NETLIFY_AUTH_TOKEN is set"
else
  test_fail "NETLIFY_AUTH_TOKEN not set" "Add to .env file"
fi

if [ -n "$NETLIFY_SITE_ID" ]; then
  test_pass "NETLIFY_SITE_ID is set"
else
  test_fail "NETLIFY_SITE_ID not set" "Add to .env file"
fi

echo ""

# ==========================================
# 3. TEST SUPABASE CONNECTION
# ==========================================

echo -e "${BLUE}[3/6] Testing Supabase Connection...${NC}"
echo ""

if command -v curl &> /dev/null; then
  # Test Supabase REST API
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "apikey: $SUPABASE_KEY" \
    -H "Authorization: Bearer $SUPABASE_KEY" \
    "$SUPABASE_URL/rest/v1/" 2>&1 || echo "000")
  
  if [ "$RESPONSE" == "200" ]; then
    test_pass "Supabase API connection successful"
  elif [ "$RESPONSE" == "000" ]; then
    test_fail "Cannot connect to Supabase" "Check your internet connection"
  else
    test_fail "Supabase API returned status $RESPONSE" "Check SUPABASE_URL and SUPABASE_KEY"
  fi
  
  # Test records table
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "apikey: $SUPABASE_KEY" \
    -H "Authorization: Bearer $SUPABASE_KEY" \
    "$SUPABASE_URL/rest/v1/records?select=count" 2>&1 || echo "000")
  
  if [ "$RESPONSE" == "200" ]; then
    test_pass "Supabase 'records' table exists"
  elif [ "$RESPONSE" == "404" ]; then
    test_fail "Supabase 'records' table not found" "Run: supabase db push"
  else
    test_warn "Could not verify 'records' table" "Might need to run migrations"
  fi
else
  test_warn "curl not installed, skipping connection tests" "Install curl to test connections"
fi

echo ""

# ==========================================
# 4. TEST NETLIFY CONNECTION
# ==========================================

echo -e "${BLUE}[4/6] Testing Netlify Connection...${NC}"
echo ""

if command -v curl &> /dev/null; then
  # Test Netlify API
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Bearer $NETLIFY_AUTH_TOKEN" \
    "https://api.netlify.com/api/v1/user" 2>&1 || echo "000")
  
  if [ "$RESPONSE" == "200" ]; then
    test_pass "Netlify API connection successful"
  elif [ "$RESPONSE" == "401" ]; then
    test_fail "Netlify authentication failed" "Check NETLIFY_AUTH_TOKEN"
  elif [ "$RESPONSE" == "000" ]; then
    test_fail "Cannot connect to Netlify" "Check your internet connection"
  else
    test_fail "Netlify API returned status $RESPONSE" "Check NETLIFY_AUTH_TOKEN"
  fi
  
  # Test site exists
  if [ -n "$NETLIFY_SITE_ID" ]; then
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
      -H "Authorization: Bearer $NETLIFY_AUTH_TOKEN" \
      "https://api.netlify.com/api/v1/sites/$NETLIFY_SITE_ID" 2>&1 || echo "000")
    
    if [ "$RESPONSE" == "200" ]; then
      test_pass "Netlify site found"
    elif [ "$RESPONSE" == "404" ]; then
      test_fail "Netlify site not found" "Check NETLIFY_SITE_ID"
    else
      test_warn "Could not verify Netlify site" "Status: $RESPONSE"
    fi
  fi
fi

echo ""

# ==========================================
# 5. TEST NOTION CONNECTION
# ==========================================

echo -e "${BLUE}[5/6] Testing Notion Connection...${NC}"
echo ""

if command -v curl &> /dev/null; then
  # Test Notion API
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Bearer $NOTION_TOKEN" \
    -H "Notion-Version: 2022-06-28" \
    "https://api.notion.com/v1/users/me" 2>&1 || echo "000")
  
  if [ "$RESPONSE" == "200" ]; then
    test_pass "Notion API connection successful"
  elif [ "$RESPONSE" == "401" ]; then
    test_fail "Notion authentication failed" "Check NOTION_TOKEN"
  elif [ "$RESPONSE" == "000" ]; then
    test_fail "Cannot connect to Notion" "Check your internet connection"
  else
    test_fail "Notion API returned status $RESPONSE" "Check NOTION_TOKEN"
  fi
  
  # Test database access
  if [ -n "$NOTION_DATABASE_ID" ]; then
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
      -H "Authorization: Bearer $NOTION_TOKEN" \
      -H "Notion-Version: 2022-06-28" \
      "https://api.notion.com/v1/databases/$NOTION_DATABASE_ID" 2>&1 || echo "000")
    
    if [ "$RESPONSE" == "200" ]; then
      test_pass "Notion database access successful"
    elif [ "$RESPONSE" == "404" ]; then
      test_fail "Notion database not found or not shared" "Share database with your integration!"
    else
      test_warn "Could not verify Notion database" "Status: $RESPONSE"
    fi
  fi
fi

echo ""

# ==========================================
# 6. CHECK PROJECT SETUP
# ==========================================

echo -e "${BLUE}[6/6] Checking Project Setup...${NC}"
echo ""

if [ -d "node_modules" ]; then
  test_pass "Dependencies installed (node_modules exists)"
else
  test_fail "Dependencies not installed" "Run: npm install"
fi

if [ -f "package.json" ]; then
  test_pass "package.json found"
else
  test_fail "package.json not found" "Are you in the project directory?"
fi

if [ -d "src" ]; then
  test_pass "Source directory exists"
else
  test_fail "Source directory not found" "Repository might be corrupted"
fi

if [ -d ".github/workflows" ]; then
  WORKFLOW_COUNT=$(ls -1 .github/workflows/*.yml 2>/dev/null | wc -l)
  test_pass "GitHub Actions workflows found ($WORKFLOW_COUNT workflows)"
else
  test_warn "GitHub Actions workflows not found" "Optional for local development"
fi

echo ""

# ==========================================
# SUMMARY
# ==========================================

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}VALIDATION SUMMARY${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""
echo -e "${GREEN}✅ Passed: $PASSED${NC}"
echo -e "${YELLOW}⚠️  Warnings: $WARNINGS${NC}"
echo -e "${RED}❌ Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}🎉 All critical checks passed!${NC}"
  echo ""
  echo "Next steps:"
  echo "1. Start the application: docker-compose up"
  echo "2. Test health endpoint: curl http://localhost:3000/health"
  echo "3. Run manual sync: curl -X POST http://localhost:3000/sync"
  echo ""
  echo "For detailed verification, see: VERIFICATION.md"
  exit 0
else
  echo -e "${RED}❌ Some checks failed. Please fix the issues above.${NC}"
  echo ""
  echo "For help:"
  echo "- See CREDENTIALS.md for credential setup"
  echo "- See SETUP_GUIDE.md for complete setup instructions"
  echo "- See docs/TROUBLESHOOTING.md for common issues"
  exit 1
fi
