# Credential Setup Guide

> **Complete reference for obtaining and configuring all credentials required for the Integration Glue Pipeline**

## Table of Contents

- [Overview](#overview)
- [Credential Checklist](#credential-checklist)
- [Security Best Practices](#security-best-practices)
- [Supabase Credentials](#supabase-credentials)
- [Netlify Credentials](#netlify-credentials)
- [Notion Credentials](#notion-credentials)
- [GitHub Credentials](#github-credentials)
- [AWS Credentials](#aws-credentials-optional)
- [Storing Credentials](#storing-credentials)
- [Credential Validation](#credential-validation)

---

## Overview

This guide provides detailed instructions for obtaining every credential needed to run the Integration Glue Pipeline. Each section includes:

✅ What the credential is used for
✅ Step-by-step instructions to obtain it
✅ Where to store it (GitHub Secrets vs `.env` file)
✅ How to verify it works

---

## Credential Checklist

Before starting, you'll need accounts with:

- [ ] **Supabase** - https://supabase.com (free tier available)
- [ ] **Netlify** - https://netlify.com (free tier available)
- [ ] **Notion** - https://notion.so (free tier available)
- [ ] **GitHub** - https://github.com (where this repo lives)
- [ ] **AWS** - https://aws.amazon.com (optional, for Terraform)

### Required Credentials Summary

| Service | Credential Name | Where to Store | Required? |
|---------|----------------|----------------|----------|
| Supabase | SUPABASE_URL | Both | ✅ Yes |
| Supabase | SUPABASE_KEY | Both | ✅ Yes |
| Supabase | SUPABASE_SERVICE_ROLE_KEY | .env only | ⚠️ Caution |
| Supabase | SUPABASE_PROJECT_REF | GitHub Secrets | ✅ Yes |
| Supabase | SUPABASE_DB_PASSWORD | GitHub Secrets | ✅ Yes |
| Supabase | SUPABASE_ACCESS_TOKEN | GitHub Secrets | ✅ Yes |
| Netlify | NETLIFY_AUTH_TOKEN | GitHub Secrets | ✅ Yes |
| Netlify | NETLIFY_SITE_ID | Both | ✅ Yes |
| Netlify | NETLIFY_SITE_URL | Both | ✅ Yes |
| Notion | NOTION_TOKEN | Both | ✅ Yes |
| Notion | NOTION_DATABASE_ID | Both | ✅ Yes |
| GitHub | GITHUB_TOKEN | .env only | Optional |
| AWS | AWS_ACCESS_KEY_ID | .env only | Optional |
| AWS | AWS_SECRET_ACCESS_KEY | .env only | Optional |

---

## Security Best Practices

### 🔒 Do's

✅ **Use GitHub Secrets** for production credentials
✅ **Rotate credentials** regularly (every 90 days)
✅ **Use different credentials** for dev/staging/production
✅ **Enable 2FA** on all service accounts
✅ **Limit token scopes** to minimum required permissions
✅ **Never commit** `.env` file to git (already in `.gitignore`)
✅ **Review access logs** periodically

### ❌ Don'ts

❌ **Never share** service role keys or admin tokens
❌ **Don't commit** credentials to version control
❌ **Don't use production credentials** for local development
❌ **Don't store credentials** in plain text files outside `.env`
❌ **Don't give excessive permissions** to API tokens

---

## Supabase Credentials

### 1. SUPABASE_URL

**What it is:** Your Supabase project API endpoint

**How to get it:**

1. Go to https://supabase.com and sign in
2. Click on your project (or create a new one)
3. Click "Settings" in the left sidebar
4. Click "API" under Project Settings
5. Find "Project URL" section
6. Copy the URL (format: `https://xxxxxxxxxxxxx.supabase.co`)

**Where to store:**
- ✅ Local `.env` file: `SUPABASE_URL=https://xxxxxxxxxxxxx.supabase.co`
- ✅ GitHub Secrets: Add as `SUPABASE_URL`

**Validation:**
```bash
curl -I https://your-project-ref.supabase.co/rest/v1/
# Should return: HTTP/2 200
```

---

### 2. SUPABASE_KEY (anon/public key)

**What it is:** Public API key for client-side requests (safe to expose)

**How to get it:**

1. Same location as SUPABASE_URL above
2. In Settings → API
3. Find "Project API keys" section
4. Copy the `anon` `public` key (starts with `eyJ...`)

**Where to store:**
- ✅ Local `.env` file: `SUPABASE_KEY=eyJhbGc...`
- ✅ GitHub Secrets: Add as `SUPABASE_KEY`

**Security note:** This key is safe to use in client-side code with Row Level Security (RLS) enabled.

---

### 3. SUPABASE_SERVICE_ROLE_KEY

**What it is:** Admin key that bypasses Row Level Security (RLS)

**How to get it:**

1. Same location: Settings → API
2. Find "Project API keys" section
3. Copy the `service_role` key
4. **⚠️ NEVER EXPOSE THIS IN CLIENT CODE**

**Where to store:**
- ✅ Local `.env` file ONLY: `SUPABASE_SERVICE_ROLE_KEY=eyJhbGc...`
- ❌ DO NOT add to GitHub Secrets unless absolutely necessary
- ❌ DO NOT commit to version control

**Security warning:** This key has admin privileges. Only use server-side.

---

### 4. SUPABASE_PROJECT_REF

**What it is:** Your project reference ID (used by Supabase CLI)

**How to get it:**

1. In your Supabase dashboard
2. Settings → General
3. Find "Reference ID" (format: `abcdefghijklmno`)
4. Or extract from your SUPABASE_URL: `https://[THIS-PART].supabase.co`

**Where to store:**
- ✅ GitHub Secrets: Add as `SUPABASE_PROJECT_REF`

**Example:** If URL is `https://xyzabc123.supabase.co`, ref is `xyzabc123`

---

### 5. SUPABASE_DB_PASSWORD

**What it is:** Database password for direct PostgreSQL connections

**How to get it:**

1. Settings → Database
2. Find "Connection string" section
3. Click "Show" next to the database password
4. Copy the password

**If you forgot the password:**
1. Settings → Database
2. Click "Reset database password"
3. Copy the new password immediately

**Where to store:**
- ✅ GitHub Secrets: Add as `SUPABASE_DB_PASSWORD`
- ⚠️ Store securely - can't be retrieved after initial creation

---

### 6. SUPABASE_ACCESS_TOKEN

**What it is:** Personal access token for Supabase CLI and API access

**How to get it:**

1. Go to https://supabase.com/dashboard/account/tokens
2. Click "Generate new token"
3. Give it a name: `integration-glue-pipeline`
4. Copy the token immediately (can't be viewed again)

**Where to store:**
- ✅ GitHub Secrets: Add as `SUPABASE_ACCESS_TOKEN`
- ✅ Local `.env` file: `SUPABASE_ACCESS_TOKEN=sbp_...`

**Scopes needed:** Read and write access to projects

---

## Netlify Credentials

### 1. NETLIFY_AUTH_TOKEN

**What it is:** Personal access token for Netlify API

**How to get it:**

1. Log in to https://app.netlify.com
2. Click your avatar → "User settings"
3. Click "Applications" in the left sidebar
4. Scroll to "Personal access tokens"
5. Click "New access token"
6. Name it: `Integration Glue Pipeline`
7. Click "Generate token"
8. Copy the token immediately

**Where to store:**
- ✅ GitHub Secrets: Add as `NETLIFY_AUTH_TOKEN`
- ✅ Local `.env` file: `NETLIFY_AUTH_TOKEN=nfp_...`

**Validation:**
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  https://api.netlify.com/api/v1/user
# Should return your user info
```

---

### 2. NETLIFY_SITE_ID

**What it is:** Unique identifier for your Netlify site

**How to get it:**

1. In Netlify dashboard, select your site (or create new one)
2. Go to "Site settings"
3. Under "General" → "Site details"
4. Find "Site ID" (format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`)
5. Click to copy

**Or from the URL:**
- When viewing your site, URL is: `https://app.netlify.com/sites/[SITE-NAME]/...`
- Site ID is in Site Settings

**Where to store:**
- ✅ GitHub Secrets: Add as `NETLIFY_SITE_ID`
- ✅ Local `.env` file: `NETLIFY_SITE_ID=xxxxxxxx-xxxx...`

---

### 3. NETLIFY_SITE_URL

**What it is:** Your Netlify site's public URL

**How to get it:**

1. In your site's overview page
2. Look for the site URL (format: `https://your-site-name.netlify.app`)
3. Or set a custom domain in Domain Settings

**Where to store:**
- ✅ GitHub Secrets: Add as `NETLIFY_SITE_URL`
- ✅ Local `.env` file: `NETLIFY_SITE_URL=https://your-site.netlify.app`

**Note:** This updates when you set a custom domain

---

## Notion Credentials

### 1. NOTION_TOKEN

**What it is:** Integration token for Notion API access

**How to get it:**

1. Go to https://www.notion.so/my-integrations
2. Click "+ New integration"
3. Fill in the form:
   - **Name:** `Integration Glue Pipeline`
   - **Associated workspace:** Select your workspace
   - **Type:** Internal integration
4. Click "Submit"
5. On the next page, copy the "Internal Integration Token"
   - Format: `secret_xxxxxxxxxxxxxxxxxxxxxxxxxxxx`

**Capabilities needed:**
- ✅ Read content
- ✅ Update content
- ✅ Insert content

**Where to store:**
- ✅ GitHub Secrets: Add as `NOTION_TOKEN`
- ✅ Local `.env` file: `NOTION_TOKEN=secret_...`

**Important:** After creating the integration, you must share your database with it!

---

### 2. NOTION_DATABASE_ID

**What it is:** The unique ID of your Notion database

**How to get it:**

1. Open your Notion database in a browser
2. Look at the URL:
   ```
   https://www.notion.so/[DATABASE_ID]?v=[VIEW_ID]
   ```
3. The DATABASE_ID is the 32-character code after `notion.so/` and before `?v=`
4. Example URL:
   ```
   https://www.notion.so/myworkspace/a1b2c3d4e5f67890a1b2c3d4e5f67890?v=...
   ```
   DATABASE_ID: `a1b2c3d4e5f67890a1b2c3d4e5f67890`

**Alternative method:**

1. Click "Share" on your database
2. Click "Copy link"
3. Extract the ID from the link

**Where to store:**
- ✅ GitHub Secrets: Add as `NOTION_DATABASE_ID`
- ✅ Local `.env` file: `NOTION_DATABASE_ID=a1b2c3d4...`

**Important: Share the database with your integration!**

1. Open the database
2. Click "Share" button (top right)
3. Click "Invite"
4. Search for your integration name: `Integration Glue Pipeline`
5. Select it and grant access

---

## GitHub Credentials

### GITHUB_TOKEN (Optional)

**What it is:** Personal access token for GitHub API

**When needed:** For automated GitHub operations (optional for this project)

**How to get it:**

1. Go to https://github.com/settings/tokens
2. Click "Generate new token" → "Generate new token (classic)"
3. Give it a name: `Integration Glue Pipeline`
4. Select scopes:
   - ✅ `repo` (Full control of private repositories)
   - ✅ `workflow` (Update GitHub Action workflows)
5. Click "Generate token"
6. Copy immediately (can't be viewed again)

**Where to store:**
- ✅ Local `.env` file ONLY: `GITHUB_TOKEN=ghp_...`
- ℹ️ Usually not needed - GitHub Actions provides `GITHUB_TOKEN` automatically

---

## AWS Credentials (Optional)

### Only needed if using Terraform for AWS infrastructure

### 1. AWS_ACCESS_KEY_ID
### 2. AWS_SECRET_ACCESS_KEY

**How to get them:**

1. Log in to AWS Console: https://console.aws.amazon.com
2. Click your username → "Security credentials"
3. Scroll to "Access keys"
4. Click "Create access key"
5. Select use case: "Application running outside AWS"
6. Click "Create access key"
7. **Download the CSV file** or copy both:
   - Access key ID (format: `AKIA...`)
   - Secret access key (format: long random string)

**Where to store:**
- ✅ Local `.env` file:
  ```
  AWS_ACCESS_KEY_ID=AKIA...
  AWS_SECRET_ACCESS_KEY=...
  AWS_REGION=us-east-1
  ```
- ⚠️ Never commit these to GitHub

**Security best practice:**
- Create an IAM user specifically for this project
- Grant only necessary permissions (EC2, ECS, CloudWatch)
- Enable MFA for the IAM user

---

## Storing Credentials

### Local Development (.env file)

1. Copy the example file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your credentials:
   ```bash
   nano .env
   # or use your preferred editor
   ```

3. Fill in all values from the sections above

4. Verify `.env` is in `.gitignore`:
   ```bash
   grep .env .gitignore
   # Should show: .env
   ```

### GitHub Secrets (Production)

1. Go to your repository: https://github.com/iacosta3994/integration-glue-pipeline

2. Click "Settings" tab

3. In the left sidebar:
   - Click "Secrets and variables"
   - Click "Actions"

4. Click "New repository secret" for each credential

5. Add these secrets (see table at top for which ones):

   ```
   Name: SUPABASE_URL
   Value: https://xxxxx.supabase.co
   ```

   ```
   Name: SUPABASE_KEY
   Value: eyJhbGc...
   ```

   (Continue for all required secrets)

6. Verify secrets are saved (you won't be able to view values again)

### Environment Variables Priority

The application loads credentials in this order:

1. **Environment variables** (highest priority)
2. **`.env` file** (local development)
3. **GitHub Secrets** (in GitHub Actions workflows)

---

## Credential Validation

### Quick Validation Script

Run this script to validate all credentials:

```bash
# Make script executable
chmod +x scripts/validate-setup.sh

# Run validation
./scripts/validate-setup.sh
```

### Manual Validation

#### Test Supabase Connection
```bash
curl -H "apikey: YOUR_SUPABASE_KEY" \
  -H "Authorization: Bearer YOUR_SUPABASE_KEY" \
  "YOUR_SUPABASE_URL/rest/v1/"
```

#### Test Netlify Connection
```bash
curl -H "Authorization: Bearer YOUR_NETLIFY_TOKEN" \
  https://api.netlify.com/api/v1/sites/YOUR_SITE_ID
```

#### Test Notion Connection
```bash
curl -H "Authorization: Bearer YOUR_NOTION_TOKEN" \
  -H "Notion-Version: 2022-06-28" \
  https://api.notion.com/v1/databases/YOUR_DATABASE_ID
```

### Expected Results

✅ **Success:** JSON response with data (status 200)
❌ **Failed:** Error message or authentication failure

---

## Credential Rotation

### When to Rotate

- 🔄 Every 90 days (recommended)
- 🔄 When a team member with access leaves
- 🔄 If credentials may have been compromised
- 🔄 After a security incident

### How to Rotate

1. Generate new credentials from each service
2. Update `.env` file locally
3. Update GitHub Secrets
4. Test with new credentials
5. Revoke old credentials
6. Document the rotation in your security log

---

## Troubleshooting

### "Invalid API key" errors

✅ Check for spaces or newlines in copied credentials
✅ Verify you copied the complete token
✅ Ensure token hasn't expired
✅ Check token has correct permissions

### "Database not found" (Notion)

✅ Verify you shared the database with your integration
✅ Check database ID format (32 characters, no dashes)
✅ Ensure integration has correct capabilities

### "Unauthorized" (Supabase)

✅ Verify you're using the correct key (anon vs service_role)
✅ Check Row Level Security (RLS) policies
✅ Ensure project isn't paused

### GitHub Secrets not working

✅ Secret names must match exactly (case-sensitive)
✅ Secrets don't show in logs (by design)
✅ Re-run the workflow after adding secrets

---

## Need Help?

- 📖 See [SETUP_GUIDE.md](./SETUP_GUIDE.md) for step-by-step deployment
- 🔍 See [VERIFICATION.md](./VERIFICATION.md) for testing your setup
- 🐛 Check [docs/TROUBLESHOOTING.md](./docs/TROUBLESHOOTING.md) for common issues
- 💬 Open an issue: https://github.com/iacosta3994/integration-glue-pipeline/issues

---

**Last Updated:** February 27, 2026  
**Author:** Ian Acosta
