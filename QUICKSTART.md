# Quick Start Guide

> **Get the Integration Glue Pipeline running in 15 minutes**

## Prerequisites Check

Before starting, make sure you have:

- [ ] **Node.js 18+** installed ([download](https://nodejs.org))
- [ ] **Docker Desktop** installed and running ([download](https://www.docker.com/products/docker-desktop))
- [ ] **Git** installed ([download](https://git-scm.com))
- [ ] Accounts created on [Supabase](https://supabase.com), [Netlify](https://netlify.com), and [Notion](https://notion.so)

**Verify:**
```bash
node --version  # Should show v18.x.x or higher
docker --version
git --version
```

---

## Step 1: Clone & Install (2 minutes)

```bash
# Clone the repository
git clone https://github.com/iacosta3994/integration-glue-pipeline.git
cd integration-glue-pipeline

# Install dependencies
npm install
```

---

## Step 2: Get Your Credentials (10 minutes)

### Supabase (3 minutes)

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Create a new project (or select existing)
3. Go to **Settings** → **API**
4. Copy these values:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **anon/public key** (starts with `eyJ...`)
5. Go to **Settings** → **General**
6. Copy **Reference ID**

### Netlify (3 minutes)

1. Go to [Netlify Dashboard](https://app.netlify.com)
2. Create a new site (any starter template)
3. Go to **Site settings** → **General** → **Site details**
4. Copy **Site ID**
5. Go to **User settings** → **Applications** → **Personal access tokens**
6. Click **New access token**, name it, and copy the token

### Notion (4 minutes)

1. Go to [My Integrations](https://www.notion.so/my-integrations)
2. Click **+ New integration**
3. Name: `Integration Glue Pipeline`
4. Select your workspace
5. Click **Submit** and copy the **Internal Integration Token**
6. Create a new database in Notion with columns:
   - **Name** (Title)
   - **Status** (Select: New, Active, Pending, Completed)
   - **Created At** (Date)
7. Click **Share** → Add your integration
8. Copy database ID from URL (32 characters before `?v=`)

---

## Step 3: Configure Environment (2 minutes)

### Option A: Interactive Setup (Recommended)

```bash
# Make script executable
chmod +x scripts/setup-credentials.sh

# Run interactive setup
./scripts/setup-credentials.sh
```

Follow the prompts and paste your credentials when asked.

### Option B: Manual Setup

```bash
# Copy template
cp .env.example .env

# Edit with your credentials
nano .env
# or
code .env  # VS Code
```

Paste the credentials you collected:

```env
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_KEY=eyJhbGc...
SUPABASE_PROJECT_REF=xxxxx
NOTION_TOKEN=secret_xxxxx
NOTION_DATABASE_ID=xxxxx
NETLIFY_AUTH_TOKEN=nfp_xxxxx
NETLIFY_SITE_ID=xxxxx-xxxxx-xxxxx
NETLIFY_SITE_URL=https://yoursite.netlify.app
```

---

## Step 4: Setup Database (1 minute)

```bash
# Install Supabase CLI (if not installed)
npm install -g supabase

# Link to your project
supabase link --project-ref YOUR_PROJECT_REF

# Run migrations
supabase db push
```

When prompted, enter your database password (from Supabase setup).

---

## Step 5: Start Application (30 seconds)

### With Docker (Recommended):

```bash
docker-compose up
```

### Or with Node directly:

```bash
npm start
```

Wait for:
```
Integration glue pipeline running on port 3000
Cron jobs scheduled successfully
```

---

## Step 6: Verify It Works (30 seconds)

Open a new terminal:

```bash
# Check health
curl http://localhost:3000/health
# Should return: {"status":"healthy",...}

# Test sync
curl -X POST http://localhost:3000/sync
# Should return: {"success":true,...}

# Check Notion database - should see 3 sample records!
```

---

## ✅ Success!

You now have:
- ✅ Application running locally
- ✅ Supabase connected with sample data
- ✅ Notion integration working
- ✅ Automated sync every hour

---

## Next Steps

### Deploy to Production

1. **Add GitHub Secrets:**
   - Go to your repo → Settings → Secrets and variables → Actions
   - Add all credentials as repository secrets
   - [Full list in CREDENTIALS.md](./CREDENTIALS.md#storing-credentials)

2. **Push to trigger deployment:**
   ```bash
   git add .
   git commit -m "Configure production"
   git push origin main
   ```

3. **Monitor deployment:**
   - Go to Actions tab in GitHub
   - Watch workflows complete

### Customize

- **Change sync schedule:** Edit `src/services/scheduler.js`
- **Modify sync logic:** Edit `src/services/sync.js`
- **Add new properties:** Update Notion database and sync code

---

## Common Issues

### "Cannot connect to Supabase"
- ✅ Check `SUPABASE_URL` has no trailing slash
- ✅ Verify project is not paused in Supabase dashboard
- ✅ Test: `curl -I $SUPABASE_URL/rest/v1/`

### "Notion database not found"
- ✅ **Most common:** Database not shared with integration!
  - Open database → Share → Add integration
- ✅ Check database ID is 32 characters (no dashes)

### "Docker won't start"
- ✅ Make sure Docker Desktop is running
- ✅ Check port 3000 is available: `lsof -i :3000`

### "npm install fails"
- ✅ Delete `node_modules` and `package-lock.json`
- ✅ Run `npm cache clean --force`
- ✅ Try again: `npm install`

---

## Full Documentation

This quick start covers the essentials. For comprehensive guides:

- **📖 [SETUP_GUIDE.md](./SETUP_GUIDE.md)** - Detailed setup with explanations
- **🔑 [CREDENTIALS.md](./CREDENTIALS.md)** - Complete credential reference
- **✅ [VERIFICATION.md](./VERIFICATION.md)** - Testing and verification
- **🔧 [TROUBLESHOOTING.md](./docs/TROUBLESHOOTING.md)** - Common issues and fixes

---

## Get Help

- **Run diagnostics:** `./scripts/validate-setup.sh`
- **Check logs:** `docker-compose logs -f app`
- **Search issues:** [GitHub Issues](https://github.com/iacosta3994/integration-glue-pipeline/issues)
- **Open new issue:** [New Issue](https://github.com/iacosta3994/integration-glue-pipeline/issues/new/choose)

---

## Video Tutorial (Coming Soon)

Looking for a video walkthrough? Check the [Wiki](https://github.com/iacosta3994/integration-glue-pipeline/wiki) for video guides.

---

**Happy integrating! 🚀**

*Questions? [Open an issue](https://github.com/iacosta3994/integration-glue-pipeline/issues/new/choose)*

---

**Last Updated:** February 27, 2026  
**Author:** Ian Acosta
