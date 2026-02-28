# Complete Setup Guide

> **Step-by-step instructions to deploy the Integration Glue Pipeline from scratch**

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Part 1: Account Setup](#part-1-account-setup)
- [Part 2: Service Configuration](#part-2-service-configuration)
- [Part 3: Local Development Setup](#part-3-local-development-setup)
- [Part 4: GitHub Configuration](#part-4-github-configuration)
- [Part 5: First Deployment](#part-5-first-deployment)
- [Part 6: Verification](#part-6-verification)
- [Next Steps](#next-steps)

---

## Overview

This guide will walk you through:
- ✅ Setting up all required service accounts
- ✅ Obtaining and configuring credentials
- ✅ Running the application locally
- ✅ Deploying to production
- ✅ Verifying everything works

**Estimated Time:** 60-90 minutes

**Difficulty:** Beginner-friendly (some command line experience helpful)

---

## Prerequisites

### Required Tools

Install these before starting:

#### 1. Node.js (v18 or higher)

**Check if installed:**
```bash
node --version
# Should show v18.x.x or higher
```

**Install if needed:**
- Mac: `brew install node`
- Windows: Download from https://nodejs.org
- Linux: `sudo apt install nodejs npm` or `sudo yum install nodejs npm`

#### 2. Git

**Check if installed:**
```bash
git --version
# Should show git version 2.x.x
```

**Install if needed:**
- Mac: `brew install git`
- Windows: Download from https://git-scm.com
- Linux: `sudo apt install git` or `sudo yum install git`

#### 3. Docker Desktop (for local development)

**Check if installed:**
```bash
docker --version
docker-compose --version
```

**Install if needed:**
- Download from https://www.docker.com/products/docker-desktop
- Follow installation wizard
- Start Docker Desktop after installation

#### 4. A Code Editor

Recommended:
- **VS Code:** https://code.visualstudio.com (recommended)
- **Sublime Text:** https://www.sublimetext.com
- Or any text editor you prefer

---

## Part 1: Account Setup

### Step 1.1: Create Supabase Account

1. Go to https://supabase.com
2. Click "Start your project"
3. Sign up with GitHub (recommended) or email
4. Verify your email if needed

### Step 1.2: Create Supabase Project

1. Click "New Project"
2. Fill in details:
   - **Name:** `integration-glue-pipeline`
   - **Database Password:** Create a strong password (save this!)
   - **Region:** Choose closest to your users (e.g., `us-east-1`)
3. Click "Create new project"
4. ⏳ Wait 2-3 minutes for project to initialize

**💾 Save your database password immediately!** You'll need it later.

### Step 1.3: Create Netlify Account

1. Go to https://www.netlify.com
2. Click "Sign up"
3. Sign up with GitHub (recommended)
4. Authorize Netlify to access your GitHub

### Step 1.4: Create Netlify Site

1. Click "Add new site" → "Import an existing project"
2. Select "GitHub"
3. Find and select `integration-glue-pipeline` repository
4. Configure build settings:
   - **Build command:** `npm run build`
   - **Publish directory:** `dist`
5. Click "Deploy site"
6. Site will deploy (may fail - that's OK for now)
7. Note your site URL (e.g., `https://random-name-123.netlify.app`)

**Optional:** Change site name:
1. Site settings → General → Site details
2. Click "Change site name"
3. Choose something memorable: `your-name-integration-glue`

### Step 1.5: Create Notion Account

1. Go to https://www.notion.so
2. Sign up if you don't have an account
3. Create or select a workspace

### Step 1.6: Create Notion Database

1. In Notion, create a new page: "Integration Data"
2. Type `/database` and select "Database - Inline"
3. Set up columns:
   - **Name:** (already exists) - Title type
   - **Status:** Select type with options: New, Active, Pending, Completed
   - **Created At:** Date type
4. Click "Share" button (top right)
5. Keep this page open - you'll need it soon

---

## Part 2: Service Configuration

### Step 2.1: Get Supabase Credentials

1. In your Supabase project dashboard:

2. **Get Project URL and Keys:**
   - Click "Settings" (gear icon) → "API"
   - Copy and save:
     - ✅ **Project URL** (e.g., `https://abcxyz123.supabase.co`)
     - ✅ **anon public** key (starts with `eyJ...`)
     - ✅ **service_role** key (starts with `eyJ...`) - keep this secret!

3. **Get Project Reference:**
   - Settings → General
   - Copy **Reference ID** (e.g., `abcxyz123`)
   - Or extract from URL: `https://[THIS-PART].supabase.co`

4. **Get Database Password:**
   - Use the password you created when setting up the project
   - If you forgot: Settings → Database → Reset database password

5. **Create Access Token:**
   - Go to https://supabase.com/dashboard/account/tokens
   - Click "Generate new token"
   - Name: `integration-glue-pipeline`
   - Copy the token immediately

### Step 2.2: Get Netlify Credentials

1. **Get Site ID:**
   - In Netlify, go to your site
   - Site settings → General → Site information
   - Copy **Site ID** (format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`)

2. **Get Site URL:**
   - Copy the URL shown at the top (e.g., `https://your-site.netlify.app`)

3. **Create Access Token:**
   - Click your avatar → User settings
   - Applications → Personal access tokens
   - Click "New access token"
   - Description: `integration-glue-pipeline`
   - Click "Generate token"
   - Copy the token immediately (starts with `nfp_...`)

### Step 2.3: Get Notion Credentials

1. **Create Integration:**
   - Go to https://www.notion.so/my-integrations
   - Click "+ New integration"
   - Name: `Integration Glue Pipeline`
   - Select your workspace
   - Capabilities: Select all (Read, Insert, Update)
   - Click "Submit"
   - Copy the **Internal Integration Token** (starts with `secret_...`)

2. **Get Database ID:**
   - Open your "Integration Data" database in a browser
   - Look at the URL:
     ```
     https://www.notion.so/[32-character-database-id]?v=...
     ```
   - Copy the 32-character ID (before `?v=`)
   - Remove any dashes if present

3. **Share Database with Integration:**
   - In your database, click "Share" (top right)
   - Click "Invite"
   - Search for: `Integration Glue Pipeline`
   - Click to add it
   - ✅ Make sure it shows in the shared list

---

## Part 3: Local Development Setup

### Step 3.1: Clone Repository

Open your terminal and run:

```bash
# Navigate to where you want the project
cd ~/Projects  # or wherever you keep code

# Clone the repository
git clone https://github.com/iacosta3994/integration-glue-pipeline.git

# Navigate into the project
cd integration-glue-pipeline
```

### Step 3.2: Create Environment File

```bash
# Copy the example environment file
cp .env.example .env
```

Now edit the `.env` file with your credentials:

```bash
# Open in your editor (choose one):
code .env              # VS Code
subl .env              # Sublime Text
nano .env              # Terminal editor
```

**Fill in ALL the values you collected above:**

```env
# Application Configuration
NODE_ENV=development
PORT=3000
LOG_LEVEL=info

# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=eyJhbGc...your-anon-key...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGc...your-service-role-key...
SUPABASE_TABLE=records
SUPABASE_PROJECT_REF=your-project-ref
SUPABASE_DB_PASSWORD=your-database-password
SUPABASE_ACCESS_TOKEN=sbp_your-access-token

# Notion Configuration
NOTION_TOKEN=secret_your-notion-token
NOTION_DATABASE_ID=your-32-character-database-id

# Netlify Configuration
NETLIFY_AUTH_TOKEN=nfp_your-netlify-token
NETLIFY_SITE_ID=your-site-id
NETLIFY_SITE_URL=https://your-site.netlify.app

# Application URLs
APP_URL=http://localhost:3000

# AWS Configuration (optional - leave blank for now)
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_REGION=us-east-1

# Redis Configuration (optional)
REDIS_URL=redis://localhost:6379
```

**Save the file** (Ctrl+S or Cmd+S)

### Step 3.3: Install Dependencies

```bash
# Install all Node.js packages
npm install

# This will take 1-2 minutes
# You'll see a progress bar
```

**Expected output:**
```
added 247 packages, and audited 248 packages in 45s
```

### Step 3.4: Set Up Supabase Database

Run the initial migration to create tables:

1. **Install Supabase CLI:**
   ```bash
   npm install -g supabase
   ```

2. **Link to your project:**
   ```bash
   supabase link --project-ref your-project-ref
   # When prompted, enter your database password
   ```

3. **Run migrations:**
   ```bash
   supabase db push
   ```

**Expected output:**
```
✅ Applying migration: 001_initial_schema.sql
✅ Migration complete
```

### Step 3.5: Test Local Setup (Without Docker)

```bash
# Start the application
npm start
```

**Expected output:**
```
Integration glue pipeline running on port 3000
Cron jobs scheduled successfully
```

**Test in another terminal:**
```bash
curl http://localhost:3000/health
```

**Expected response:**
```json
{
  "status": "healthy",
  "timestamp": "2026-02-27T22:46:00.000Z",
  "version": "1.0.0"
}
```

✅ **Success!** Press Ctrl+C to stop the server.

### Step 3.6: Test with Docker (Recommended)

```bash
# Make sure Docker Desktop is running
# Then start all services:
docker-compose up
```

**First run takes 2-5 minutes to download images**

**Expected output:**
```
Creating integration-glue-pipeline ... done
Creating integration-redis         ... done
Attaching to integration-glue-pipeline, integration-redis
...
integration-glue-pipeline | Integration glue pipeline running on port 3000
```

**Test in another terminal:**
```bash
curl http://localhost:3000/health
```

✅ **Success!** Your local environment is working.

**To stop:**
```bash
# Press Ctrl+C, then:
docker-compose down
```

---

## Part 4: GitHub Configuration

### Step 4.1: Add GitHub Secrets

1. Go to your repository:
   ```
   https://github.com/iacosta3994/integration-glue-pipeline
   ```

2. Click **Settings** tab (top of page)

3. In left sidebar:
   - Click **Secrets and variables**
   - Click **Actions**

4. Click **New repository secret** button

5. Add each secret one by one:

   | Name | Value (from your .env file) |
   |------|-----------------------------|
   | `SUPABASE_URL` | Your Supabase project URL |
   | `SUPABASE_KEY` | Your Supabase anon key |
   | `SUPABASE_PROJECT_REF` | Your project reference ID |
   | `SUPABASE_DB_PASSWORD` | Your database password |
   | `SUPABASE_ACCESS_TOKEN` | Your Supabase access token |
   | `NETLIFY_AUTH_TOKEN` | Your Netlify personal token |
   | `NETLIFY_SITE_ID` | Your Netlify site ID |
   | `NETLIFY_SITE_URL` | Your Netlify site URL |
   | `NOTION_TOKEN` | Your Notion integration token |
   | `NOTION_DATABASE_ID` | Your Notion database ID |
   | `APP_URL` | Your production URL (use Netlify URL for now) |

   **For each secret:**
   - Click "New repository secret"
   - Enter the **Name** exactly as shown (case-sensitive)
   - Paste the **Value**
   - Click "Add secret"

6. **Verify all secrets are added:**
   - You should see 11 secrets listed
   - ✅ Double-check spelling of each name

### Step 4.2: Enable GitHub Actions

1. In your repository, click **Actions** tab

2. If you see "Workflows need permission":
   - Click "I understand my workflows, go ahead and enable them"

3. You should see 5 workflows:
   - ✅ CI/CD Pipeline
   - ✅ Deploy to Netlify
   - ✅ Health Check
   - ✅ Migrate Supabase Database
   - ✅ Setup Notion Database

---

## Part 5: First Deployment

### Step 5.1: Trigger Deployment

Simply push a change to the main branch:

```bash
# Make a small change
echo "\n# Deployed on $(date)" >> README.md

# Commit and push
git add README.md
git commit -m "Trigger first deployment"
git push origin main
```

### Step 5.2: Monitor Deployment

1. Go to **Actions** tab in GitHub

2. You should see workflows running:
   - 🟡 **CI/CD Pipeline** - Running
   - 🟡 **Deploy to Netlify** - Running
   - 🟡 **Migrate Supabase Database** - Running

3. Click on "CI/CD Pipeline" to watch progress

4. Each job will show:
   - 🟡 Yellow circle: Running
   - ✅ Green check: Success
   - ❌ Red X: Failed (see logs)

**Expected timeline:**
- Test & Lint: ~2 minutes
- Build Docker Image: ~3 minutes
- Deploy: ~2 minutes
- **Total: ~7-10 minutes**

### Step 5.3: Check Deployment Status

**In Netlify:**
1. Go to your Netlify dashboard
2. Select your site
3. Click "Deploys"
4. Latest deploy should show "Published"
5. Click site URL to view (may show 404 - that's OK)

**In Supabase:**
1. Go to your Supabase dashboard
2. Click "Database" → "Tables"
3. You should see:
   - ✅ `records` table
   - ✅ `sync_logs` table
4. Click `records` table → should have 3 sample rows

---

## Part 6: Verification

### Step 6.1: Run Verification Script

```bash
# Make sure you're in the project directory
cd ~/Projects/integration-glue-pipeline

# Run health checks
npm run health-check
```

**Expected output:**
```
🏥 Starting health checks...

✅ Application: Healthy
✅ Netlify: Healthy
✅ Supabase: Healthy

✅ All services healthy
```

### Step 6.2: Test Notion Integration

1. **Run manual sync:**
   ```bash
   curl -X POST http://localhost:3000/sync
   ```

2. **Check Notion:**
   - Open your "Integration Data" database in Notion
   - You should see 3 new entries:
     - Sample Record 1
     - Sample Record 2
     - Sample Record 3
   - Each with status and created date

3. **If you don't see them:**
   - Check you shared the database with your integration
   - Verify NOTION_DATABASE_ID is correct
   - Check application logs for errors

### Step 6.3: Test Automated Workflows

1. **Test Notion Setup Workflow:**
   - Go to GitHub → Actions tab
   - Click "Setup Notion Database"
   - Click "Run workflow" dropdown
   - Select action: "validate"
   - Click "Run workflow" button
   - Wait for completion (should be green ✅)

2. **Test Health Check Workflow:**
   - Go to Actions tab
   - Click "Health Check"
   - Click "Run workflow"
   - Click "Run workflow" button
   - Should complete in ~2 minutes with ✅

---

## Next Steps

### ✅ You're all set! Now you can:

1. **Monitor health checks:**
   - Automated checks run every 5 minutes
   - View in GitHub Actions tab

2. **Add real data:**
   - Insert records into Supabase `records` table
   - They'll auto-sync to Notion every hour
   - Or trigger manual sync: `curl -X POST localhost:3000/sync`

3. **Customize the integration:**
   - Edit `src/services/sync.js` to change sync logic
   - Modify `src/services/scheduler.js` to change schedule
   - Update Notion properties in `src/services/sync.js`

4. **Set up custom domain (optional):**
   - In Netlify: Domain settings → Add custom domain
   - Update `NETLIFY_SITE_URL` in GitHub Secrets

5. **Add production database:**
   - Create separate Supabase project for production
   - Use different credentials in GitHub Secrets
   - Keep development credentials in local `.env`

### 📚 Additional Resources

- **Full Credentials Guide:** [CREDENTIALS.md](./CREDENTIALS.md)
- **Verification Guide:** [VERIFICATION.md](./VERIFICATION.md)
- **Troubleshooting:** [docs/TROUBLESHOOTING.md](./docs/TROUBLESHOOTING.md)
- **API Documentation:** Check `src/` folder for inline comments

### 💬 Get Help

- **Issues:** https://github.com/iacosta3994/integration-glue-pipeline/issues
- **Discussions:** https://github.com/iacosta3994/integration-glue-pipeline/discussions

---

## Common Issues During Setup

### "Cannot find module" errors
```bash
# Delete node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

### Docker won't start
```bash
# Make sure Docker Desktop is running
# Then try:
docker-compose down
docker-compose up --build
```

### "Invalid API key" errors
- Double-check you copied complete keys (no spaces)
- Verify no extra characters or line breaks
- Check `.env` file has no quotes around values

### Notion integration not working
- **Most common:** Database not shared with integration
- Go to database → Share → Add your integration
- Wait 1 minute and try again

### GitHub Actions failing
- Check all secrets are added
- Names must match exactly (case-sensitive)
- Re-run workflow after adding missing secrets

---

**Congratulations! 🎉**

You've successfully set up the Integration Glue Pipeline!

**Last Updated:** February 27, 2026  
**Author:** Ian Acosta
