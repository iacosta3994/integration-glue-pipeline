#!/bin/bash

# Credential Setup Helper Script
# Author: Ian Acosta
# Description: Interactive script to help gather and validate credentials

set -e

echo "🔑 Integration Glue Pipeline - Credential Setup Helper"
echo "========================================================"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if .env already exists
if [ -f .env ]; then
  echo -e "${YELLOW}⚠️  .env file already exists!${NC}"
  read -p "Do you want to overwrite it? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Exiting without changes."
    exit 0
  fi
  mv .env .env.backup.$(date +%Y%m%d_%H%M%S)
  echo -e "${GREEN}✅ Backed up existing .env file${NC}"
fi

# Copy from example
cp .env.example .env
echo -e "${GREEN}✅ Created .env file from template${NC}"
echo ""

# Helper function to prompt for input
prompt_credential() {
  local var_name=$1
  local description=$2
  local guide_url=$3
  local default_value=$4
  
  echo -e "${BLUE}❓ $description${NC}"
  if [ -n "$guide_url" ]; then
    echo -e "   ${YELLOW}How to get it: $guide_url${NC}"
  fi
  
  if [ -n "$default_value" ]; then
    read -p "   Enter value (default: $default_value): " value
    value=${value:-$default_value}
  else
    read -p "   Enter value: " value
  fi
  
  # Update .env file
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s|^${var_name}=.*|${var_name}=${value}|" .env
  else
    # Linux
    sed -i "s|^${var_name}=.*|${var_name}=${value}|" .env
  fi
  
  echo -e "${GREEN}✅ Set $var_name${NC}"
  echo ""
}

# Validate URL format
validate_url() {
  local url=$1
  if [[ $url =~ ^https?:// ]]; then
    return 0
  else
    return 1
  fi
}

echo -e "${BLUE}🚀 Let's set up your credentials!${NC}"
echo ""
echo "This script will ask you for each credential needed."
echo "You can find detailed instructions in CREDENTIALS.md"
echo ""
read -p "Press Enter to continue..."
echo ""

# ==========================================
# SUPABASE CREDENTIALS
# ==========================================

echo -e "${YELLOW}=== SUPABASE CREDENTIALS ===${NC}"
echo ""

prompt_credential "SUPABASE_URL" \
  "Supabase Project URL (e.g., https://xxxxx.supabase.co)" \
  "Dashboard → Settings → API → Project URL" \
  ""

prompt_credential "SUPABASE_KEY" \
  "Supabase Anon/Public Key (starts with eyJ...)" \
  "Dashboard → Settings → API → anon public key" \
  ""

prompt_credential "SUPABASE_SERVICE_ROLE_KEY" \
  "Supabase Service Role Key (starts with eyJ...) - KEEP SECRET!" \
  "Dashboard → Settings → API → service_role key" \
  ""

prompt_credential "SUPABASE_PROJECT_REF" \
  "Supabase Project Reference ID" \
  "Dashboard → Settings → General → Reference ID" \
  ""

prompt_credential "SUPABASE_DB_PASSWORD" \
  "Supabase Database Password" \
  "Dashboard → Settings → Database → Database password" \
  ""

prompt_credential "SUPABASE_ACCESS_TOKEN" \
  "Supabase Access Token (starts with sbp_...)" \
  "https://supabase.com/dashboard/account/tokens" \
  ""

# ==========================================
# NOTION CREDENTIALS
# ==========================================

echo -e "${YELLOW}=== NOTION CREDENTIALS ===${NC}"
echo ""

prompt_credential "NOTION_TOKEN" \
  "Notion Integration Token (starts with secret_...)" \
  "https://www.notion.so/my-integrations" \
  ""

prompt_credential "NOTION_DATABASE_ID" \
  "Notion Database ID (32 characters, no dashes)" \
  "Copy from database URL" \
  ""

echo -e "${RED}⚠️  IMPORTANT: Make sure to share your Notion database with the integration!${NC}"
echo "   1. Open your database in Notion"
echo "   2. Click 'Share' (top right)"
echo "   3. Add your integration"
echo ""
read -p "Press Enter when you've shared the database..."
echo ""

# ==========================================
# NETLIFY CREDENTIALS
# ==========================================

echo -e "${YELLOW}=== NETLIFY CREDENTIALS ===${NC}"
echo ""

prompt_credential "NETLIFY_AUTH_TOKEN" \
  "Netlify Personal Access Token (starts with nfp_...)" \
  "User Settings → Applications → Personal access tokens" \
  ""

prompt_credential "NETLIFY_SITE_ID" \
  "Netlify Site ID (UUID format)" \
  "Site Settings → General → Site information → Site ID" \
  ""

prompt_credential "NETLIFY_SITE_URL" \
  "Netlify Site URL (e.g., https://your-site.netlify.app)" \
  "Copy from site overview" \
  ""

# ==========================================
# OPTIONAL: AWS CREDENTIALS
# ==========================================

echo -e "${YELLOW}=== AWS CREDENTIALS (Optional) ===${NC}"
echo ""
echo "AWS credentials are only needed if using Terraform for infrastructure."
read -p "Do you want to configure AWS credentials? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
  prompt_credential "AWS_ACCESS_KEY_ID" \
    "AWS Access Key ID (starts with AKIA...)" \
    "AWS Console → Security credentials → Access keys" \
    ""
  
  prompt_credential "AWS_SECRET_ACCESS_KEY" \
    "AWS Secret Access Key" \
    "From the same place as Access Key ID" \
    ""
  
  prompt_credential "AWS_REGION" \
    "AWS Region" \
    "Choose closest to your users" \
    "us-east-1"
fi

echo ""
echo -e "${GREEN}✅ All credentials configured!${NC}"
echo ""

# ==========================================
# VALIDATION
# ==========================================

echo -e "${BLUE}🔍 Validating credentials...${NC}"
echo ""

# Load environment variables
set -a
source .env
set +a

# Validate Supabase URL
if validate_url "$SUPABASE_URL"; then
  echo -e "${GREEN}✅ SUPABASE_URL format is valid${NC}"
else
  echo -e "${RED}❌ SUPABASE_URL format is invalid${NC}"
fi

# Validate Netlify URL
if validate_url "$NETLIFY_SITE_URL"; then
  echo -e "${GREEN}✅ NETLIFY_SITE_URL format is valid${NC}"
else
  echo -e "${RED}❌ NETLIFY_SITE_URL format is invalid${NC}"
fi

# Check key prefixes
if [[ $SUPABASE_KEY == eyJ* ]]; then
  echo -e "${GREEN}✅ SUPABASE_KEY format looks correct${NC}"
else
  echo -e "${YELLOW}⚠️  SUPABASE_KEY might be incorrect (should start with 'eyJ')${NC}"
fi

if [[ $NOTION_TOKEN == secret_* ]]; then
  echo -e "${GREEN}✅ NOTION_TOKEN format looks correct${NC}"
else
  echo -e "${YELLOW}⚠️  NOTION_TOKEN might be incorrect (should start with 'secret_')${NC}"
fi

if [[ $NETLIFY_AUTH_TOKEN == nfp_* ]]; then
  echo -e "${GREEN}✅ NETLIFY_AUTH_TOKEN format looks correct${NC}"
else
  echo -e "${YELLOW}⚠️  NETLIFY_AUTH_TOKEN might be incorrect (should start with 'nfp_')${NC}"
fi

echo ""
echo -e "${BLUE}=== NEXT STEPS ===${NC}"
echo ""
echo "1. Review your .env file: cat .env"
echo "2. Test connections: npm run health-check"
echo "3. Start application: docker-compose up"
echo ""
echo -e "${BLUE}For detailed testing, see: VERIFICATION.md${NC}"
echo ""
echo -e "${GREEN}✅ Setup complete!${NC}"
