---
name: Bug Report
about: Report a bug or unexpected behavior
title: '[BUG] '
labels: bug
assignees: ''
---

## Bug Description

**A clear and concise description of what the bug is.**

## Steps to Reproduce

1. Go to '...'
2. Click on '...'
3. Run command '...'
4. See error

## Expected Behavior

**What you expected to happen:**

## Actual Behavior

**What actually happened:**

## Error Messages

```
Paste any error messages or logs here
```

## Environment

**Please complete the following information:**

- OS: [e.g., macOS 13.0, Ubuntu 22.04, Windows 11]
- Node.js version: [run `node --version`]
- npm version: [run `npm --version`]
- Docker version (if using): [run `docker --version`]
- Browser (if applicable): [e.g., Chrome 120, Safari 17]

## Configuration

**Are you running:**
- [ ] Locally with Docker
- [ ] Locally with Node.js directly
- [ ] In production (GitHub Actions)
- [ ] Other (please specify)

**Which workflow/service is affected?**
- [ ] CI/CD Pipeline
- [ ] Supabase integration
- [ ] Notion integration
- [ ] Netlify deployment
- [ ] Health checks
- [ ] Other (please specify)

## Logs

**Relevant log output (if available):**

<details>
<summary>Application Logs</summary>

```
Paste logs here
```

</details>

<details>
<summary>Docker Logs (if using Docker)</summary>

```bash
# Output of: docker-compose logs
Paste logs here
```

</details>

## Additional Context

**Add any other context about the problem here. Screenshots can be helpful!**

## Checklist

**Before submitting, please verify:**

- [ ] I have searched existing issues to avoid duplicates
- [ ] I have read the [Troubleshooting Guide](../docs/TROUBLESHOOTING.md)
- [ ] I have verified my credentials in `.env` file
- [ ] I have run `npm run health-check` or `./scripts/validate-setup.sh`
- [ ] I have included all relevant error messages
- [ ] I have checked GitHub Actions logs (if applicable)

## Possible Solution

**If you have ideas on how to fix this, please share:**
