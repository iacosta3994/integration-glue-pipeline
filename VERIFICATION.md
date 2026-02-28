# Verification & Testing Guide

> **Complete guide to verify your Integration Glue Pipeline setup is working correctly**

## Table of Contents

- [Quick Health Check](#quick-health-check)
- [Service-by-Service Verification](#service-by-service-verification)
- [Integration Testing](#integration-testing)
- [Automated Tests](#automated-tests)
- [Monitoring & Alerts](#monitoring--alerts)
- [Troubleshooting](#troubleshooting)

---

## Quick Health Check

### 1-Minute Verification

Run this command to check all services:

```bash
npm run health-check
```

**Expected Output:**
```
🏥 Starting health checks...

✅ Application: Healthy
✅ Netlify: Healthy  
✅ Supabase: Healthy

✅ All services healthy
```

**If any service shows ❌:**
- Jump to [Service-by-Service Verification](#service-by-service-verification) section below
- Check the specific service's documentation

---

## Service-by-Service Verification

### Supabase Verification

#### Test 1: Database Connection

```bash
curl -H "apikey: $SUPABASE_KEY" \
  -H "Authorization: Bearer $SUPABASE_KEY" \
  "$SUPABASE_URL/rest/v1/"
```

**Expected:** Empty JSON response `{}`

**If failed:**
- ❌ **401 Unauthorized:** Check your `SUPABASE_KEY`
- ❌ **404 Not Found:** Check your `SUPABASE_URL`
- ❌ **Connection refused:** Check Supabase project is not paused

#### Test 2: Query Records Table

```bash
curl -H "apikey: $SUPABASE_KEY" \
  -H "Authorization: Bearer $SUPABASE_KEY" \
  "$SUPABASE_URL/rest/v1/records?select=*"
```

**Expected:** Array of records (should have 3 sample records)

```json
[
  {
    "id": "uuid-here",
    "name": "Sample Record 1",
    "status": "Active",
    "created_at": "2026-02-27T..."
  },
  ...
]
```

**If failed:**
- ❌ **Empty array `[]`:** Run database migrations (see below)
- ❌ **"relation does not exist":** Table not created, run migrations
- ❌ **403 Forbidden:** Check Row Level Security (RLS) policies

**Fix: Run migrations**
```bash
supabase db push
```

#### Test 3: Insert Test Record

```bash
curl -X POST "$SUPABASE_URL/rest/v1/records" \
  -H "apikey: $SUPABASE_KEY" \
  -H "Authorization: Bearer $SUPABASE_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Record",
    "description": "Testing insert",
    "status": "New"
  }'
```

**Expected:** Created record with generated `id`

**Verify in Supabase Dashboard:**
1. Go to Supabase dashboard
2. Database → Tables → `records`
3. Should see "Test Record" in the table

✅ **Supabase is working correctly**

---

### Netlify Verification

#### Test 1: API Connection

```bash
curl -H "Authorization: Bearer $NETLIFY_AUTH_TOKEN" \
  https://api.netlify.com/api/v1/user
```

**Expected:** Your user information in JSON format

```json
{
  "id": "...",
  "email": "your-email@example.com",
  "full_name": "Your Name",
  ...
}
```

**If failed:**
- ❌ **401 Unauthorized:** Check `NETLIFY_AUTH_TOKEN`
- ❌ **Token expired:** Generate new token in Netlify dashboard

#### Test 2: Get Site Information

```bash
curl -H "Authorization: Bearer $NETLIFY_AUTH_TOKEN" \
  "https://api.netlify.com/api/v1/sites/$NETLIFY_SITE_ID"
```

**Expected:** Site details including URL, deploy status

```json
{
  "id": "your-site-id",
  "name": "your-site-name",
  "url": "https://your-site.netlify.app",
  "published_deploy": {...}
}
```

**If failed:**
- ❌ **404 Not Found:** Check `NETLIFY_SITE_ID` is correct
- ❌ **Site not found:** Verify site exists in Netlify dashboard

#### Test 3: Check Site URL

```bash
curl -I $NETLIFY_SITE_URL
```

**Expected:** HTTP 200 or 404 (either is fine - site is responding)

**Verify in Browser:**
1. Open `$NETLIFY_SITE_URL` in browser
2. Should load (even if showing 404 or default page)
3. ❌ If "site not found" → Check DNS/deployment

✅ **Netlify is working correctly**

---

### Notion Verification

#### Test 1: Integration Connection

```bash
curl -H "Authorization: Bearer $NOTION_TOKEN" \
  -H "Notion-Version: 2022-06-28" \
  https://api.notion.com/v1/users/me
```

**Expected:** Integration user information

```json
{
  "object": "user",
  "id": "...",
  "type": "bot",
  "bot": {
    "owner": {...},
    "workspace_name": "Your Workspace"
  }
}
```

**If failed:**
- ❌ **401 Unauthorized:** Check `NOTION_TOKEN` (should start with `secret_`)
- ❌ **Invalid token:** Generate new integration token

#### Test 2: Database Access

```bash
curl -H "Authorization: Bearer $NOTION_TOKEN" \
  -H "Notion-Version: 2022-06-28" \
  "https://api.notion.com/v1/databases/$NOTION_DATABASE_ID"
```

**Expected:** Database structure with properties

```json
{
  "object": "database",
  "id": "your-database-id",
  "title": [{"text": {"content": "Integration Data"}}],
  "properties": {
    "Name": {...},
    "Status": {...},
    "Created At": {...}
  }
}
```

**If failed:**
- ❌ **404 Not Found:** Check `NOTION_DATABASE_ID` (32 characters, no dashes)
- ❌ **Object not found:** Database might not be shared with integration
- ❌ **Could not find database:** Database ID is incorrect

**Fix: Share database with integration**
1. Open database in Notion
2. Click "Share" (top right)
3. Add your integration: "Integration Glue Pipeline"
4. Verify it appears in shared list
5. Wait 30 seconds and retry

#### Test 3: Query Database

```bash
curl -X POST "https://api.notion.com/v1/databases/$NOTION_DATABASE_ID/query" \
  -H "Authorization: Bearer $NOTION_TOKEN" \
  -H "Notion-Version: 2022-06-28" \
  -H "Content-Type: application/json" \
  -d '{
    "page_size": 10
  }'
```

**Expected:** List of pages in database (may be empty initially)

```json
{
  "object": "list",
  "results": [...],
  "next_cursor": null,
  "has_more": false
}
```

✅ **Notion is working correctly**

---

### Local Application Verification

#### Test 1: Start Application

```bash
# If using Docker
docker-compose up -d

# Or directly with Node
npm start
```

**Wait 10 seconds for startup**

#### Test 2: Health Endpoint

```bash
curl http://localhost:3000/health
```

**Expected:**
```json
{
  "status": "healthy",
  "timestamp": "2026-02-27T22:46:00.000Z",
  "version": "1.0.0"
}
```

**If failed:**
- ❌ **Connection refused:** App not running or port conflict
- ❌ **Port already in use:** Change `PORT` in `.env` file

#### Test 3: Manual Sync

```bash
curl -X POST http://localhost:3000/sync
```

**Expected:**
```json
{
  "success": true,
  "message": "Sync completed successfully"
}
```

**Verify:**
1. Check application logs:
   ```bash
   # If using Docker:
   docker-compose logs -f app
   
   # Look for:
   # "Starting data synchronization"
   # "Fetched X records from Supabase"
   # "Synced record XXX to Notion"
   ```

2. Check Notion database:
   - Open your "Integration Data" database
   - Should see new entries with data from Supabase

3. Check Supabase:
   - Database → `sync_logs` table
   - Should see log entries with status "success"

✅ **Application is working correctly**

---

## Integration Testing

### End-to-End Flow Test

This tests the complete data flow: Supabase → Application → Notion

#### Step 1: Clear Test Data (Optional)

In Notion, delete any existing test records so you can see new ones clearly.

#### Step 2: Create Test Record in Supabase

```bash
curl -X POST "$SUPABASE_URL/rest/v1/records" \
  -H "apikey: $SUPABASE_KEY" \
  -H "Authorization: Bearer $SUPABASE_KEY" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d '{
    "name": "E2E Test Record",
    "description": "Testing end-to-end flow",
    "status": "Active"
  }'
```

**Note the returned `id` value**

#### Step 3: Trigger Sync

```bash
curl -X POST http://localhost:3000/sync
```

#### Step 4: Verify in Notion

1. Open your Notion database
2. Refresh the page (Cmd+R or F5)
3. Look for "E2E Test Record"
4. Verify:
   - ✅ Name matches: "E2E Test Record"
   - ✅ Status is: "Active"
   - ✅ Created At has a date

#### Step 5: Check Sync Logs

```bash
curl -H "apikey: $SUPABASE_KEY" \
  -H "Authorization: Bearer $SUPABASE_KEY" \
  "$SUPABASE_URL/rest/v1/sync_logs?select=*&order=synced_at.desc&limit=5"
```

**Expected:** Recent sync logs showing successful syncs

✅ **End-to-end integration is working!**

---

## Automated Tests

### GitHub Actions Workflow Tests

#### Test 1: CI/CD Pipeline

1. Go to GitHub repository
2. Actions tab → "CI/CD Pipeline"
3. Click "Run workflow" → "Run workflow"
4. Wait for completion (~5-7 minutes)

**Verify:**
- ✅ Test & Lint: Green checkmark
- ✅ Build Docker Image: Green checkmark
- ✅ Deploy (if on main branch): Green checkmark

#### Test 2: Health Check Workflow

1. Actions → "Health Check"
2. Click "Run workflow" → "Run workflow"
3. Wait for completion (~2 minutes)

**Verify:**
- ✅ All steps complete successfully
- ✅ "All services are healthy" message in logs

#### Test 3: Notion Setup Workflow

1. Actions → "Setup Notion Database"
2. Click "Run workflow"
3. Select action: "validate"
4. Click "Run workflow"
5. Wait for completion (~1 minute)

**Verify:**
- ✅ "Notion connection validated" in logs

#### Test 4: Database Migration Workflow

**Note:** Only runs when migration files change, or manually

1. Actions → "Migrate Supabase Database"
2. Click "Run workflow" → "Run workflow"
3. Wait for completion (~2 minutes)

**Verify:**
- ✅ "Database migrations completed successfully"

---

## Monitoring & Alerts

### Automated Monitoring

The Health Check workflow runs **every 5 minutes** automatically.

**To check recent runs:**
1. Go to Actions → Health Check
2. View recent workflow runs
3. All should be green ✅

**If a health check fails:**
- GitHub will show a red ❌
- Workflow log will show which service failed
- Check that service's configuration

### Manual Monitoring

#### Check Application Logs

```bash
# If using Docker:
docker-compose logs -f app

# Look for:
# - "Integration glue pipeline running on port 3000"
# - "Cron jobs scheduled successfully"
# - "Starting data synchronization" (every hour)
```

#### Check Sync History

Query sync logs to see recent synchronizations:

```bash
curl -H "apikey: $SUPABASE_KEY" \
  -H "Authorization: Bearer $SUPABASE_KEY" \
  "$SUPABASE_URL/rest/v1/sync_logs?select=*&order=synced_at.desc&limit=10"
```

**Look for:**
- Recent timestamps (within last hour)
- Status: "success"
- No error_messages

#### Monitor in Supabase Dashboard

1. Go to Supabase dashboard
2. Logs & Reports → Logs
3. Filter by time period
4. Look for API requests and errors

#### Monitor in Netlify

1. Go to Netlify dashboard
2. Analytics → View analytics
3. Check deploy status and site performance

---

## Troubleshooting

### Common Issues

#### Issue: "Sync completed but no records in Notion"

**Diagnosis:**
```bash
# Check if records exist in Supabase
curl -H "apikey: $SUPABASE_KEY" \
  -H "Authorization: Bearer $SUPABASE_KEY" \
  "$SUPABASE_URL/rest/v1/records?select=count"
```

**Possible causes:**
1. ❌ Database not shared with integration
   - **Fix:** Share database in Notion → Share → Add integration

2. ❌ Wrong database ID
   - **Fix:** Verify `NOTION_DATABASE_ID` is correct 32-char ID

3. ❌ Property mismatch
   - **Fix:** Check Notion database has properties: Name, Status, Created At

#### Issue: "401 Unauthorized" errors

**Diagnosis:** Check which service is failing

**Fixes:**
- Supabase: Verify `SUPABASE_KEY` is correct
- Netlify: Generate new `NETLIFY_AUTH_TOKEN`
- Notion: Generate new `NOTION_TOKEN`

#### Issue: Docker container won't start

**Diagnosis:**
```bash
docker-compose logs app
```

**Common causes:**
1. Port 3000 already in use
   - **Fix:** Change `PORT` in `.env` and `docker-compose.yml`

2. Missing .env file
   - **Fix:** `cp .env.example .env` and fill in values

3. Build errors
   - **Fix:** `docker-compose down && docker-compose up --build`

#### Issue: GitHub Actions failing

**Check:**
1. All secrets are added (11 required)
2. Secret names match exactly (case-sensitive)
3. No typos in secret values

**Fix:**
1. Settings → Secrets and variables → Actions
2. Review all secrets
3. Delete and re-add any suspicious ones
4. Re-run workflow

### Getting More Help

**Check logs in order:**

1. **Application logs** (most detailed):
   ```bash
   docker-compose logs -f app
   # or
   cat logs/combined.log
   ```

2. **GitHub Actions logs**:
   - Actions tab → Select workflow → Select run → View logs

3. **Service dashboards**:
   - Supabase: Logs & Reports
   - Netlify: Deploys → Deploy log
   - Notion: No logs available

**Still stuck?**
- 📖 Check [CREDENTIALS.md](./CREDENTIALS.md)
- 📖 Check [SETUP_GUIDE.md](./SETUP_GUIDE.md)
- 🐛 See [docs/TROUBLESHOOTING.md](./docs/TROUBLESHOOTING.md)
- 💬 Open an issue: https://github.com/iacosta3994/integration-glue-pipeline/issues

---

## Verification Checklist

Use this checklist to confirm everything is working:

### Local Development
- [ ] `.env` file created and populated
- [ ] `npm install` completed successfully
- [ ] Docker containers start without errors
- [ ] Health endpoint returns `{"status": "healthy"}`
- [ ] Manual sync creates records in Notion
- [ ] Application logs show no errors

### Supabase
- [ ] Project is active (not paused)
- [ ] Database tables exist (`records`, `sync_logs`)
- [ ] Sample data present in `records` table
- [ ] API endpoint responds to requests
- [ ] Can query records via REST API

### Netlify
- [ ] Site is deployed
- [ ] Site URL is accessible
- [ ] API token has correct permissions
- [ ] Site ID matches dashboard

### Notion
- [ ] Integration created
- [ ] Database exists with correct properties
- [ ] Database is shared with integration
- [ ] API token works
- [ ] Can query database via API
- [ ] Synced records appear in database

### GitHub
- [ ] All 11 secrets added
- [ ] Workflows enabled
- [ ] CI/CD Pipeline runs successfully
- [ ] Health Check workflow passes
- [ ] Notion validation workflow passes

### Integration
- [ ] End-to-end sync works (Supabase → Notion)
- [ ] Sync logs recorded in Supabase
- [ ] Scheduled syncs run hourly
- [ ] No errors in application logs
- [ ] All health checks green

✅ **If all items are checked, your setup is complete and verified!**

---

**Last Updated:** February 27, 2026  
**Author:** Ian Acosta
