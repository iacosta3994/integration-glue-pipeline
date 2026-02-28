# Scripts Directory

This directory contains helper scripts for managing the Integration Glue Pipeline.

## Available Scripts

### Setup & Validation

#### `setup-credentials.sh`
Interactive script to help you gather and configure all required credentials.

**Usage:**
```bash
chmod +x scripts/setup-credentials.sh
./scripts/setup-credentials.sh
```

**What it does:**
- Creates `.env` file from template
- Prompts for each credential with helpful guidance
- Validates credential formats
- Provides next steps

**When to use:** First time setup or when reconfiguring credentials

---

#### `validate-setup.sh`
Comprehensive validation of your entire setup.

**Usage:**
```bash
chmod +x scripts/validate-setup.sh
./scripts/validate-setup.sh
```

**What it checks:**
- ✅ Required tools installed (Node.js, Docker, Git)
- ✅ Environment variables configured
- ✅ Supabase connection and database tables
- ✅ Netlify API access and site existence
- ✅ Notion API access and database sharing
- ✅ Project dependencies installed

**When to use:** 
- After initial setup
- When troubleshooting issues
- Before deploying to production
- Periodically to ensure everything works

---

### Deployment

#### `deploy.sh`
Automated deployment script for production.

**Usage:**
```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh [environment] [branch]
```

**Examples:**
```bash
# Deploy production from main branch
./scripts/deploy.sh production main

# Deploy staging from develop branch
./scripts/deploy.sh staging develop

# Default: production from main
./scripts/deploy.sh
```

**What it does:**
1. Pulls latest changes from git
2. Installs dependencies
3. Runs tests
4. Builds Docker image
5. Stops existing containers
6. Starts new containers
7. Performs health check

**When to use:** Manual production deployments (automated via GitHub Actions)

---

#### `migrate.sh`
Run Supabase database migrations.

**Usage:**
```bash
chmod +x scripts/migrate.sh
./scripts/migrate.sh
```

**What it does:**
- Loads environment variables from `.env`
- Installs Supabase CLI if needed
- Pushes migrations to database

**When to use:**
- After creating new migration files
- When setting up a new database
- Manually applying schema changes

---

## Making Scripts Executable

All scripts need to be made executable before first use:

```bash
# Make all scripts executable at once
chmod +x scripts/*.sh

# Or individually
chmod +x scripts/setup-credentials.sh
chmod +x scripts/validate-setup.sh
chmod +x scripts/deploy.sh
chmod +x scripts/migrate.sh
```

## Script Permissions

If you get "Permission denied" errors:

```bash
# Check current permissions
ls -l scripts/

# Make executable for user
chmod u+x scripts/setup-credentials.sh

# Make executable for everyone
chmod +x scripts/setup-credentials.sh

# Or use with bash explicitly
bash scripts/setup-credentials.sh
```

## Windows Users

On Windows, use Git Bash or WSL to run these scripts:

### Using Git Bash:
```bash
bash scripts/setup-credentials.sh
```

### Using WSL (Windows Subsystem for Linux):
```bash
# Convert line endings if needed
dos2unix scripts/*.sh

# Then run normally
./scripts/setup-credentials.sh
```

### Using PowerShell:
For PowerShell users, we recommend using WSL or Git Bash, but you can also run Node.js scripts directly:

```powershell
npm run health-check
```

## Common Issues

### "Command not found"

**Problem:** Script not in PATH or not executable

**Solution:**
```bash
# Use ./ prefix
./scripts/validate-setup.sh

# Or full path
bash /path/to/integration-glue-pipeline/scripts/validate-setup.sh
```

### "Permission denied"

**Problem:** Script not executable

**Solution:**
```bash
chmod +x scripts/validate-setup.sh
```

### "Bad interpreter"

**Problem:** Wrong line endings (Windows)

**Solution:**
```bash
# Install dos2unix
sudo apt install dos2unix  # Ubuntu/Debian
brew install dos2unix      # macOS

# Convert line endings
dos2unix scripts/*.sh
```

## Script Environment

All scripts expect to be run from the project root directory:

```bash
# CORRECT
cd integration-glue-pipeline
./scripts/validate-setup.sh

# INCORRECT
cd integration-glue-pipeline/scripts
./validate-setup.sh  # May not find .env file
```

## Script Dependencies

### `setup-credentials.sh`
- **Requires:** bash, sed
- **Creates:** `.env` file
- **Reads:** `.env.example`

### `validate-setup.sh`
- **Requires:** bash, curl, node, npm
- **Reads:** `.env` file
- **Tests:** All service APIs

### `deploy.sh`
- **Requires:** bash, git, npm, docker, docker-compose
- **Reads:** `.env` file
- **Actions:** Deploys application

### `migrate.sh`
- **Requires:** bash, supabase CLI
- **Reads:** `.env` file, `supabase/migrations/`
- **Actions:** Updates database schema

## Getting Help

If you encounter issues with scripts:

1. **Check script output** - Scripts provide helpful error messages
2. **Verify prerequisites** - Ensure required tools are installed
3. **Check permissions** - Scripts must be executable
4. **Review documentation:**
   - [SETUP_GUIDE.md](../SETUP_GUIDE.md)
   - [VERIFICATION.md](../VERIFICATION.md)
   - [docs/TROUBLESHOOTING.md](../docs/TROUBLESHOOTING.md)

## Contributing

When adding new scripts:

1. Add shebang: `#!/bin/bash`
2. Add `set -e` for error handling
3. Add helpful comments
4. Include usage instructions
5. Update this README
6. Make executable: `chmod +x scripts/new-script.sh`

---

**Quick Reference:**

```bash
# First time setup
./scripts/setup-credentials.sh

# Validate everything
./scripts/validate-setup.sh

# Deploy application
./scripts/deploy.sh

# Run migrations
./scripts/migrate.sh
```

---

**Author:** Ian Acosta  
**Last Updated:** February 27, 2026
