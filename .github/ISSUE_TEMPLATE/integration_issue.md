---
name: Integration Issue
about: Report an issue with Supabase, Netlify, or Notion integration
title: '[INTEGRATION] '
labels: integration, bug
assignees: ''
---

## Which Service?

**Which service integration is having issues?**

- [ ] Supabase
- [ ] Netlify
- [ ] Notion
- [ ] Multiple services

## Issue Description

**Describe the integration issue:**

## Expected Behavior

**What should happen with the integration:**

## Actual Behavior

**What's actually happening:**

## Service Status

**Have you checked if the service is operational?**

- Supabase Status: https://status.supabase.com
- Netlify Status: https://www.netlifystatus.com
- Notion Status: https://status.notion.so

## Credential Verification

### Supabase (if applicable)

- [ ] SUPABASE_URL is set correctly
- [ ] SUPABASE_KEY is valid (anon/public key)
- [ ] Supabase project is not paused
- [ ] Database tables exist (`records`, `sync_logs`)
- [ ] Row Level Security (RLS) policies allow access

**Test command result:**
```bash
# curl -I $SUPABASE_URL/rest/v1/
Paste result here
```

### Netlify (if applicable)

- [ ] NETLIFY_AUTH_TOKEN is valid
- [ ] NETLIFY_SITE_ID is correct
- [ ] Site exists and is deployed
- [ ] No recent breaking changes to site

**Test command result:**
```bash
# curl -H "Authorization: Bearer $NETLIFY_AUTH_TOKEN" https://api.netlify.com/api/v1/user
Paste result here
```

### Notion (if applicable)

- [ ] NOTION_TOKEN is valid (starts with `secret_`)
- [ ] NOTION_DATABASE_ID is correct (32 characters)
- [ ] Database is shared with the integration
- [ ] Integration has correct capabilities (Read, Insert, Update)
- [ ] Database properties match expected schema

**Test command result:**
```bash
# curl -H "Authorization: Bearer $NOTION_TOKEN" -H "Notion-Version: 2022-06-28" https://api.notion.com/v1/databases/$NOTION_DATABASE_ID
Paste result here
```

## Error Messages

**Paste any relevant error messages:**

```
Error messages here
```

## Logs

**Application logs showing the integration issue:**

<details>
<summary>Application Logs</summary>

```
Paste logs here
```

</details>

**Service-specific logs (if available):**

<details>
<summary>Service Logs</summary>

```
Paste logs here
```

</details>

## Sync History

**If this is a sync issue, what do the sync logs show?**

```sql
-- Query Supabase sync_logs table:
-- SELECT * FROM sync_logs ORDER BY synced_at DESC LIMIT 10;
Paste results here
```

## Data Flow

**Describe the data flow where the issue occurs:**

1. Data is created in [Supabase/Notion]
2. Sync is triggered [automatically/manually]
3. Expected: Data appears in [Notion/Supabase]
4. Actual: [What happens instead]

## Timing

**When did this issue start?**

- [ ] Just started
- [ ] After a recent change (describe below)
- [ ] Intermittent (works sometimes)
- [ ] Never worked

**Recent changes:**
- 

## Frequency

**How often does this issue occur?**

- [ ] Every time
- [ ] Intermittently
- [ ] Only for specific data
- [ ] Random

## Workaround

**Have you found any workaround?**

## Impact

**How is this affecting your workflow?**

- [ ] Blocking - Cannot use the integration
- [ ] Severe - Major functionality broken
- [ ] Moderate - Some features not working
- [ ] Minor - Cosmetic or edge case

## Additional Context

**Any other relevant information:**

## Checklist

- [ ] I have verified my credentials are correct
- [ ] I have checked the service status pages
- [ ] I have reviewed the integration code in `src/services/`
- [ ] I have tested the service API directly (using curl)
- [ ] I have checked [VERIFICATION.md](../../VERIFICATION.md) for testing steps
- [ ] I have reviewed recent changes to my configuration
