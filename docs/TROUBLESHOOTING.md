# Troubleshooting Guide

> **Common issues and their solutions for the Integration Glue Pipeline**

## Table of Contents

- [Quick Diagnostics](#quick-diagnostics)
- [Installation Issues](#installation-issues)
- [Credential Issues](#credential-issues)
- [Supabase Issues](#supabase-issues)
- [Netlify Issues](#netlify-issues)
- [Notion Issues](#notion-issues)
- [Docker Issues](#docker-issues)
- [GitHub Actions Issues](#github-actions-issues)
- [Application Issues](#application-issues)
- [Sync Issues](#sync-issues)
- [Performance Issues](#performance-issues)
- [Getting Additional Help](#getting-additional-help)

---

## Quick Diagnostics

### Run Automated Validation

**First step for any issue:**

```bash
# Make script executable
chmod +x scripts/validate-setup.sh

# Run validation
./scripts/validate-setup.sh
```

This will check:
- ✅ Required tools installed
- ✅ Environment variables configured
- ✅ Service connections working
- ✅ Project files in place

### Check Service Health

```bash
npm run health-check
```

### View Logs

```bash
# Docker logs
docker-compose logs -f app

# Local application logs
tail -f logs/combined.log

# Error logs only
tail -f logs/error.log
```

---

## Installation Issues

### Issue: "npm install" fails

**Error:**
```
npm ERR! code EACCES
npm ERR! syscall access
```

**Solutions:**

1. **Clear npm cache:**
   ```bash
   npm cache clean --force
   rm -rf node_modules package-lock.json
   npm install
   ```

2. **Check Node.js version:**
   ```bash
   node --version
   # Must be v18.0.0 or higher
   ```

3. **Use correct permissions (Linux/Mac):**
   ```bash
   sudo chown -R $(whoami) ~/.npm
   sudo chown -R $(whoami) node_modules
   ```

4. **On Windows, run as Administrator:**
   - Right-click Command Prompt/PowerShell
   - Select "Run as Administrator"
   - Navigate to project directory
   - Run `npm install`

---

### Issue: "Cannot find module"

**Error:**
```
Error: Cannot find module 'express'
```

**Solution:**

```bash
# Delete and reinstall dependencies
rm -rf node_modules package-lock.json
npm install

# Verify installation
ls node_modules | grep express
```

---

### Issue: Node.js version mismatch

**Error:**
```
engine "node" is incompatible with this module
```

**Solution:**

1. **Check required version:**
   ```bash
   cat package.json | grep -A 2 '"engines"'
   # Shows: "node": ">=18.0.0"
   ```

2. **Install correct version:**
   ```bash
   # Using nvm (recommended)
   nvm install 18
   nvm use 18
   
   # Or download from https://nodejs.org
   ```

3. **Verify:**
   ```bash
   node --version
   # Should show v18.x.x or higher
   ```

---

## Credential Issues

### Issue: "Invalid API key" or "401 Unauthorized"

**Common causes:**

1. **Extra spaces or newlines in credentials**
   
   **Check:**
   ```bash
   # Print credential (safely)
   echo "$SUPABASE_KEY" | wc -c
   # Should be ~200+ characters for JWT tokens
   ```
   
   **Fix:** Re-copy the credential, ensuring no extra characters

2. **Wrong credential used**
   
   - Supabase: Using service_role key instead of anon key (or vice versa)
   - Notion: Using wrong integration token
   - Netlify: Using expired or revoked token
   
   **Fix:** Re-generate the credential from the service dashboard

3. **Credential expired**
   
   **Fix:** Generate a new token:
   - Supabase: https://supabase.com/dashboard/account/tokens
   - Netlify: User Settings → Applications → New access token
   - Notion: https://www.notion.so/my-integrations (regenerate)

---

### Issue: ".env file not loading"

**Symptoms:**
- Variables are `undefined`
- Application can't connect to services

**Solutions:**

1. **Verify .env exists:**
   ```bash
   ls -la .env
   # Should show the file
   ```

2. **Check format (no quotes needed):**
   ```bash
   # CORRECT:
   SUPABASE_URL=https://example.supabase.co
   
   # INCORRECT:
   SUPABASE_URL="https://example.supabase.co"  # Don't use quotes
   SUPABASE_URL = https://example.supabase.co  # Don't use spaces
   ```

3. **Ensure dotenv is loaded:**
   ```javascript
   // In src/index.js - should be at the top
   import dotenv from 'dotenv';
   dotenv.config();
   ```

4. **Test loading:**
   ```bash
   node -e "require('dotenv').config(); console.log(process.env.SUPABASE_URL)"
   # Should print your Supabase URL
   ```

---

## Supabase Issues

### Issue: "Cannot connect to Supabase"

**Error:**
```
Fetch failed: https://xxx.supabase.co/rest/v1/
```

**Diagnostic:**
```bash
curl -I $SUPABASE_URL/rest/v1/
```

**Solutions:**

1. **Check project is active:**
   - Go to Supabase dashboard
   - Verify project is not paused
   - Restore if paused

2. **Verify URL format:**
   ```bash
   echo $SUPABASE_URL
   # Should be: https://[PROJECT-REF].supabase.co
   # No trailing slash
   ```

3. **Check API key:**
   ```bash
   # Test with curl
   curl -H "apikey: $SUPABASE_KEY" \
     -H "Authorization: Bearer $SUPABASE_KEY" \
     "$SUPABASE_URL/rest/v1/"
   # Should return: {}
   ```

4. **Network/firewall issues:**
   ```bash
   # Test basic connectivity
   ping $(echo $SUPABASE_URL | sed 's|https://||' | sed 's|/.*||')
   ```

---

### Issue: "Table does not exist"

**Error:**
```
relation "public.records" does not exist
```

**Solution:**

```bash
# Run database migrations
supabase link --project-ref YOUR_PROJECT_REF
supabase db push

# Verify tables created
curl -H "apikey: $SUPABASE_KEY" \
  -H "Authorization: Bearer $SUPABASE_KEY" \
  "$SUPABASE_URL/rest/v1/"
# Should list: ["records", "sync_logs"]
```

**Alternative (manual):**

1. Go to Supabase dashboard
2. SQL Editor
3. Copy contents of `supabase/migrations/001_initial_schema.sql`
4. Run the SQL

---

### Issue: "403 Forbidden" from Supabase

**Error:**
```
{"code":"42501","message":"new row violates row-level security policy"}
```

**Cause:** Row Level Security (RLS) is blocking the request

**Solutions:**

1. **Disable RLS (development only):**
   ```sql
   ALTER TABLE records DISABLE ROW LEVEL SECURITY;
   ALTER TABLE sync_logs DISABLE ROW LEVEL SECURITY;
   ```

2. **Or add RLS policies:**
   ```sql
   -- Allow all operations for authenticated users
   CREATE POLICY "Allow all for authenticated users" ON records
     FOR ALL USING (auth.role() = 'authenticated');
   
   -- Allow read for anonymous users
   CREATE POLICY "Allow read for anon" ON records
     FOR SELECT USING (true);
   ```

3. **Use service_role key (bypasses RLS):**
   - Only for server-side code
   - Never expose in client-side code
   - Update `SUPABASE_KEY` to service_role key value

---

## Netlify Issues

### Issue: "Netlify deployment fails"

**Error in GitHub Actions:**
```
Error: Netlify authentication failed
```

**Solutions:**

1. **Verify GitHub Secrets:**
   - Settings → Secrets and variables → Actions
   - Check `NETLIFY_AUTH_TOKEN` exists
   - Check `NETLIFY_SITE_ID` exists

2. **Regenerate Netlify token:**
   - Netlify → User settings → Applications
   - Revoke old token
   - Generate new token
   - Update GitHub Secret

3. **Verify site ID:**
   ```bash
   curl -H "Authorization: Bearer $NETLIFY_AUTH_TOKEN" \
     https://api.netlify.com/api/v1/sites/$NETLIFY_SITE_ID
   # Should return site information
   ```

---

### Issue: "Build command failed"

**Error:**
```
Error during build:
Command failed with exit code 1: npm run build
```

**Solutions:**

1. **Add build script to package.json:**
   ```json
   {
     "scripts": {
       "build": "echo 'No build needed' && mkdir -p dist && touch dist/index.html"
     }
   }
   ```

2. **Or update netlify.toml:**
   ```toml
   [build]
     command = "echo 'No build step'"
     publish = "."
   ```

3. **For actual builds:**
   ```bash
   # Test locally first
   npm run build
   # Fix any build errors before pushing
   ```

---

## Notion Issues

### Issue: "Notion database not found" (404)

**Error:**
```
{"object":"error","status":404,"code":"object_not_found"}
```

**Most common cause: Database not shared with integration!**

**Solution:**

1. **Share the database:**
   - Open your database in Notion
   - Click "Share" (top right corner)
   - Click "Invite"
   - Search for your integration: "Integration Glue Pipeline"
   - Select it and click "Invite"
   - Verify it appears in the shared list

2. **Wait 30 seconds and retry**

3. **Verify database ID:**
   ```bash
   # Should be 32 characters, no dashes
   echo $NOTION_DATABASE_ID | wc -c
   # Should output: 33 (32 chars + newline)
   ```

4. **Extract ID correctly from URL:**
   ```
   URL: https://www.notion.so/myworkspace/a1b2c3d4e5f67890a1b2c3d4e5f67890?v=...
   ID:  a1b2c3d4e5f67890a1b2c3d4e5f67890
   
   # If URL has dashes, remove them:
   a1b2c3d4-e5f6-7890-a1b2-c3d4e5f67890  # WRONG
   a1b2c3d4e5f67890a1b2c3d4e5f67890    # CORRECT
   ```

---

### Issue: "Notion API returns 400 Bad Request"

**Error:**
```
{"object":"error","status":400,"code":"validation_error"}
```

**Common causes:**

1. **Property mismatch:**
   
   Your Notion database properties must match the code:
   
   **Required properties:**
   - `Name` - Title type
   - `Status` - Select type
   - `Created At` - Date type
   
   **Fix:** Add missing properties to your Notion database

2. **Invalid property values:**
   
   ```javascript
   // In src/services/sync.js
   // Make sure Status values match your database
   Status: {
     select: {
       name: record.status || 'New',  // Must be: New, Active, Pending, or Completed
     },
   }
   ```

3. **Wrong Notion API version:**
   ```bash
   # Always use: Notion-Version: 2022-06-28
   curl -H "Notion-Version: 2022-06-28" ...
   ```

---

### Issue: "Notion integration token invalid"

**Error:**
```
{"object":"error","status":401,"code":"unauthorized"}
```

**Solutions:**

1. **Verify token format:**
   ```bash
   echo $NOTION_TOKEN | grep "^secret_"
   # Should start with "secret_"
   ```

2. **Regenerate token:**
   - Go to https://www.notion.so/my-integrations
   - Click your integration
   - "Secrets" tab
   - "Regenerate secret"
   - Copy new token
   - Update `.env` file

3. **Test token:**
   ```bash
   curl -H "Authorization: Bearer $NOTION_TOKEN" \
     -H "Notion-Version: 2022-06-28" \
     https://api.notion.com/v1/users/me
   # Should return bot user info
   ```

---

## Docker Issues

### Issue: "Port 3000 already in use"

**Error:**
```
ERROR: for app  Cannot start service app: driver failed
Error starting userland proxy: listen tcp4 0.0.0.0:3000: bind: address already in use
```

**Solutions:**

1. **Find what's using the port:**
   ```bash
   # macOS/Linux
   lsof -i :3000
   
   # Or
   netstat -an | grep 3000
   ```

2. **Kill the process:**
   ```bash
   # Kill by port
   kill $(lsof -t -i:3000)
   ```

3. **Or change the port:**
   ```bash
   # Edit .env
   PORT=3001
   
   # Edit docker-compose.yml
   ports:
     - "3001:3001"  # Change both sides
   
   # Restart
   docker-compose down
   docker-compose up
   ```

---

### Issue: "Docker won't start" or "Cannot connect to Docker daemon"

**Error:**
```
Cannot connect to the Docker daemon at unix:///var/run/docker.sock
```

**Solutions:**

1. **Start Docker Desktop:**
   - macOS: Open Docker Desktop from Applications
   - Windows: Open Docker Desktop from Start Menu
   - Linux: `sudo systemctl start docker`

2. **Wait for Docker to be ready:**
   - Look for "Docker Desktop is running" in system tray
   - Can take 30-60 seconds to start

3. **Verify Docker is running:**
   ```bash
   docker ps
   # Should list containers (or show empty table)
   ```

---

### Issue: "Container exits immediately"

**Error:**
```
app_1  | Error: Cannot find module 'express'
app_1 exited with code 1
```

**Solution:**

```bash
# Rebuild without cache
docker-compose down
docker-compose build --no-cache
docker-compose up
```

---

### Issue: "Out of disk space"

**Error:**
```
no space left on device
```

**Solution:**

```bash
# Clean up Docker
docker system prune -a --volumes

# This removes:
# - All stopped containers
# - All networks not used by at least one container
# - All images without at least one container
# - All build cache
# - All volumes not used by at least one container

# Warning: This will delete data!
```

---

## GitHub Actions Issues

### Issue: "Workflow fails with 'Secret not found'"

**Error in workflow:**
```
Error: Input required and not supplied: SUPABASE_URL
```

**Solution:**

1. **Add missing secret:**
   - Go to repository Settings
   - Secrets and variables → Actions
   - New repository secret
   - Name must match EXACTLY (case-sensitive)
   - Value from your `.env` file

2. **Verify all 11 required secrets:**
   ```
   SUPABASE_URL
   SUPABASE_KEY
   SUPABASE_PROJECT_REF
   SUPABASE_DB_PASSWORD
   SUPABASE_ACCESS_TOKEN
   NETLIFY_AUTH_TOKEN
   NETLIFY_SITE_ID
   NETLIFY_SITE_URL
   NOTION_TOKEN
   NOTION_DATABASE_ID
   APP_URL
   ```

3. **Re-run workflow** after adding secrets

---

### Issue: "Workflow never triggers"

**Possible causes:**

1. **Workflows not enabled:**
   - Go to Actions tab
   - Click "I understand my workflows, go ahead and enable them"

2. **Branch name doesn't match:**
   ```yaml
   # In .github/workflows/*.yml
   on:
     push:
       branches: [main]  # Only runs on 'main' branch
   ```
   
   **Fix:** Push to correct branch or update workflow file

3. **File path triggers:**
   ```yaml
   # Migrate workflow only runs when migrations change
   on:
     push:
       paths:
         - 'supabase/migrations/**'
   ```

---

### Issue: "Actions quota exceeded"

**Error:**
```
This workflow was skipped because you have exceeded your GitHub Actions quota
```

**Solutions:**

1. **Check usage:**
   - Settings → Billing → Actions
   - View current usage

2. **Reduce frequency:**
   ```yaml
   # In .github/workflows/health-check.yml
   on:
     schedule:
       - cron: '*/30 * * * *'  # Change from */5 to */30 (every 30 min)
   ```

3. **Disable non-critical workflows:**
   - Actions tab → Select workflow → ⋮ menu → Disable

---

## Application Issues

### Issue: "Application won't start"

**Error:**
```
node:internal/modules/cjs/loader:1078
  throw err;
  ^

Error: Cannot find module './utils/logger.js'
```

**Solutions:**

1. **Check file structure:**
   ```bash
   ls -R src/
   # Should show:
   # src/index.js
   # src/services/sync.js
   # src/services/scheduler.js
   # src/utils/logger.js
   # src/healthCheck.js
   ```

2. **Reinstall dependencies:**
   ```bash
   rm -rf node_modules
   npm install
   ```

3. **Check for syntax errors:**
   ```bash
   npm run lint
   ```

---

### Issue: "Health endpoint returns 500"

**Error:**
```
curl http://localhost:3000/health
{"error":"Internal Server Error"}
```

**Diagnostic:**

```bash
# Check application logs
docker-compose logs app
# or
tail -f logs/error.log
```

**Common causes:**

1. **Missing environment variables**
2. **Database connection failed**
3. **Notion API error**

**Fix:** Check logs for specific error, then fix that service

---

## Sync Issues

### Issue: "Sync runs but no data appears in Notion"

**Diagnostic checklist:**

```bash
# 1. Check Supabase has data
curl -H "apikey: $SUPABASE_KEY" \
  -H "Authorization: Bearer $SUPABASE_KEY" \
  "$SUPABASE_URL/rest/v1/records?select=*"
# Should return array with records

# 2. Check sync logs
curl -H "apikey: $SUPABASE_KEY" \
  -H "Authorization: Bearer $SUPABASE_KEY" \
  "$SUPABASE_URL/rest/v1/sync_logs?select=*&order=synced_at.desc&limit=5"
# Check status and error_message fields

# 3. Check application logs
docker-compose logs app | grep -i "sync"
# Look for error messages
```

**Common causes:**

1. **Database not shared with integration** (most common!)
   - Share Notion database with your integration
   - Wait 30 seconds
   - Retry sync

2. **Property mismatch**
   - Verify Notion database has: Name, Status, Created At
   - Check property types match

3. **Silent failures**
   - Check `sync_logs` table for errors
   - Enable debug logging:
     ```bash
     # In .env
     LOG_LEVEL=debug
     ```

---

### Issue: "Duplicate records in Notion"

**Cause:** No duplicate detection logic

**Solutions:**

1. **Manual cleanup:**
   - Delete duplicates in Notion
   
2. **Add duplicate detection (requires code change):**
   ```javascript
   // In src/services/sync.js
   // Before creating, check if exists
   const existing = await notion.databases.query({
     database_id: databaseId,
     filter: {
       property: 'Name',
       title: {
         equals: record.name
       }
     }
   });
   
   if (existing.results.length === 0) {
     // Create new page
   }
   ```

---

## Performance Issues

### Issue: "Sync is very slow"

**If syncing many records:**

1. **Add batching:**
   ```javascript
   // Process in batches of 10
   for (let i = 0; i < records.length; i += 10) {
     const batch = records.slice(i, i + 10);
     await Promise.all(batch.map(r => syncToNotion(notion, r)));
   }
   ```

2. **Reduce sync frequency:**
   ```javascript
   // In src/services/scheduler.js
   cron.schedule('0 */2 * * *', ...);  // Every 2 hours instead of 1
   ```

3. **Add caching:**
   - Use Redis (already in docker-compose.yml)
   - Cache Notion database queries

---

### Issue: "High memory usage"

**Solutions:**

1. **Limit query results:**
   ```javascript
   // In src/services/sync.js
   .limit(100)  // Increase from 100 if needed, but not too much
   ```

2. **Add pagination:**
   ```javascript
   // Process in pages
   let page = 0;
   const pageSize = 100;
   while (true) {
     const { data } = await supabase
       .from('records')
       .select('*')
       .range(page * pageSize, (page + 1) * pageSize - 1);
     
     if (data.length === 0) break;
     await processRecords(data);
     page++;
   }
   ```

---

## Getting Additional Help

### Before Opening an Issue

1. **Run diagnostics:**
   ```bash
   ./scripts/validate-setup.sh
   npm run health-check
   ```

2. **Check documentation:**
   - [SETUP_GUIDE.md](../SETUP_GUIDE.md)
   - [CREDENTIALS.md](../CREDENTIALS.md)
   - [VERIFICATION.md](../VERIFICATION.md)

3. **Search existing issues:**
   - https://github.com/iacosta3994/integration-glue-pipeline/issues

### Opening an Issue

**Use the appropriate template:**

- [Bug Report](https://github.com/iacosta3994/integration-glue-pipeline/issues/new?template=bug_report.md) - Something isn't working
- [Setup Help](https://github.com/iacosta3994/integration-glue-pipeline/issues/new?template=setup_help.md) - Need setup assistance  
- [Integration Issue](https://github.com/iacosta3994/integration-glue-pipeline/issues/new?template=integration_issue.md) - Service integration problem

**Include:**
- ✅ Output of `./scripts/validate-setup.sh`
- ✅ Relevant error messages
- ✅ Application logs
- ✅ Steps to reproduce
- ✅ What you've already tried

### Service Status Pages

**Always check if the service is down:**

- **Supabase:** https://status.supabase.com
- **Netlify:** https://www.netlifystatus.com  
- **Notion:** https://status.notion.so
- **GitHub:** https://www.githubstatus.com

---

## Common Error Messages Reference

| Error | Likely Cause | Quick Fix |
|-------|--------------|----------|
| `EACCES` | Permission denied | Run with sudo or fix permissions |
| `EADDRINUSE` | Port already in use | Change port or kill process |
| `ECONNREFUSED` | Service not running | Start the service |
| `404` | Resource not found | Check URL/ID is correct |
| `401` | Invalid credentials | Regenerate token |
| `403` | Permission denied | Check API permissions/RLS |
| `500` | Server error | Check service logs |
| `Module not found` | Missing dependency | Run `npm install` |
| `CORS error` | Cross-origin issue | Not applicable for this project |
| `Timeout` | Network/slow response | Check internet, increase timeout |

---

**Still stuck?**

[Open an issue](https://github.com/iacosta3994/integration-glue-pipeline/issues/new/choose) with:
- Complete error message
- Output of validation script
- What you've tried
- Your environment details

We're here to help! 💚

---

**Last Updated:** February 27, 2026  
**Author:** Ian Acosta
