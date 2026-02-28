# Integration Glue Pipeline

> **A comprehensive integration pipeline connecting Netlify, Supabase, and Notion with automated deployment, database migrations, and health monitoring.**

[![CI/CD Pipeline](https://github.com/iacosta3994/integration-glue-pipeline/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/iacosta3994/integration-glue-pipeline/actions/workflows/ci-cd.yml)
[![Health Check](https://github.com/iacosta3994/integration-glue-pipeline/actions/workflows/health-check.yml/badge.svg)](https://github.com/iacosta3994/integration-glue-pipeline/actions/workflows/health-check.yml)

---

## 🚀 Quick Start

**New to this project? Start here:**

1. **📝 [Read SETUP_GUIDE.md](./SETUP_GUIDE.md)** - Complete step-by-step setup instructions
2. **🔑 [Read CREDENTIALS.md](./CREDENTIALS.md)** - Get all required API keys and tokens  
3. **✅ [Read VERIFICATION.md](./VERIFICATION.md)** - Verify everything is working

**Already set up?** Jump to [Usage](#usage) below.

---

## Overview

This project provides a robust integration layer that connects multiple services:

- **🐳 Supabase**: Backend database and authentication
- **🌐 Netlify**: Frontend hosting and deployment  
- **📓 Notion**: Content management and documentation

Data flows automatically: **Supabase → Application → Notion**

---

## Features

- ✅ **Automated CI/CD** - GitHub Actions pipeline for testing and deployment
- ✅ **Docker Support** - Containerized for consistent environments
- ✅ **Database Migrations** - Automated Supabase schema management
- ✅ **Health Monitoring** - Automated checks every 5 minutes
- ✅ **Infrastructure as Code** - Terraform for AWS resources
- ✅ **Auto-sync** - Hourly data synchronization to Notion
- ✅ **Comprehensive Docs** - Step-by-step guides for everything

---

## Prerequisites

### Required Accounts (All have free tiers)

- [ ] **GitHub** - https://github.com (where you are now!)
- [ ] **Supabase** - https://supabase.com
- [ ] **Netlify** - https://netlify.com  
- [ ] **Notion** - https://notion.so

### Required Software

- [ ] **Node.js 18+** - https://nodejs.org
- [ ] **Docker Desktop** - https://www.docker.com/products/docker-desktop
- [ ] **Git** - https://git-scm.com

**Installation help:** See [SETUP_GUIDE.md](./SETUP_GUIDE.md#prerequisites)

---

## Installation

### 1. Clone Repository

```bash
git clone https://github.com/iacosta3994/integration-glue-pipeline.git
cd integration-glue-pipeline
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Configure Environment

```bash
# Copy example environment file
cp .env.example .env

# Edit .env and fill in your credentials
# See CREDENTIALS.md for how to obtain each one
```

### 4. Set Up Database

```bash
# Install Supabase CLI
npm install -g supabase

# Link to your project
supabase link --project-ref YOUR_PROJECT_REF

# Run migrations
supabase db push
```

### 5. Start Application

**Option A: With Docker (Recommended)**
```bash
docker-compose up
```

**Option B: Direct with Node**
```bash
npm start
```

### 6. Verify Setup

```bash
# Check health
curl http://localhost:3000/health

# Should return: {"status":"healthy",...}

# Run full verification
npm run health-check
```

✅ **You're ready!** See [Usage](#usage) below.

**Having issues?** See [Troubleshooting](#troubleshooting)

---

## Usage

### Health Check

Check if all services are healthy:

```bash
curl http://localhost:3000/health
```

### Manual Sync

Trigger data sync from Supabase to Notion:

```bash
curl -X POST http://localhost:3000/sync
```

### View Logs

```bash
# Docker logs
docker-compose logs -f app

# Local logs
tail -f logs/combined.log
```

### Add Data

1. Insert records into Supabase `records` table
2. Wait for next scheduled sync (every hour)
3. Or trigger manual sync (see above)
4. Check Notion database for new entries

---

## Project Structure

```
.
├── .github/
│   ├── workflows/          # GitHub Actions CI/CD
│   └── ISSUE_TEMPLATE/    # Issue templates
├── src/
│   ├── index.js           # Main application
│   ├── services/          # Sync & scheduling logic
│   ├── utils/             # Logger & helpers
│   └── healthCheck.js     # Health monitoring
├── scripts/               # Automation scripts
├── terraform/             # Infrastructure as Code
├── docker/                # Docker configs
├── supabase/              # Database migrations
├── docs/                  # Additional documentation
├── CREDENTIALS.md         # 🔑 Credential setup guide
├── SETUP_GUIDE.md         # 📖 Complete setup walkthrough
├── VERIFICATION.md        # ✅ Testing & verification
├── docker-compose.yml    # Local development
├── Dockerfile            # Container definition
├── netlify.toml          # Netlify config
└── package.json          # Dependencies
```

---

## GitHub Actions Workflows

This project includes automated workflows:

### CI/CD Pipeline
**Triggers:** Push to `main` or `develop`, Pull requests  
**Actions:** Test → Build → Deploy

### Deploy to Netlify
**Triggers:** Push to `main`  
**Actions:** Build and deploy to Netlify

### Migrate Supabase Database  
**Triggers:** Changes to `supabase/migrations/`, Manual  
**Actions:** Run database migrations

### Setup Notion Database
**Triggers:** Manual only  
**Actions:** Validate, setup, or sync Notion database

### Health Check
**Triggers:** Every 5 minutes, Manual  
**Actions:** Verify all services are healthy

**View workflows:** [Actions tab](https://github.com/iacosta3994/integration-glue-pipeline/actions)

---

## Configuration

### Environment Variables

All configuration is done via environment variables. See [.env.example](./.env.example) for all options.

**Required variables:**
- `SUPABASE_URL` - Your Supabase project URL
- `SUPABASE_KEY` - Supabase anon/public key
- `NOTION_TOKEN` - Notion integration token
- `NOTION_DATABASE_ID` - Target Notion database ID
- `NETLIFY_AUTH_TOKEN` - Netlify API token
- `NETLIFY_SITE_ID` - Your Netlify site ID

**See [CREDENTIALS.md](./CREDENTIALS.md) for detailed instructions on obtaining each credential.**

### GitHub Secrets

For production deployment, add these secrets to your repository:

1. Go to Settings → Secrets and variables → Actions
2. Add each credential as a repository secret
3. See [CREDENTIALS.md](./CREDENTIALS.md#storing-credentials) for the complete list

---

## Deployment

### Automatic Deployment

Push to `main` branch triggers automatic deployment:

```bash
git add .
git commit -m "Your changes"
git push origin main
```

Workflows will automatically:
1. ✅ Run tests and linting
2. ✅ Build Docker image
3. ✅ Deploy to Netlify
4. ✅ Run database migrations
5. ✅ Perform health checks

### Manual Deployment

```bash
# Run deployment script
chmod +x scripts/deploy.sh
./scripts/deploy.sh production main
```

**See [SETUP_GUIDE.md](./SETUP_GUIDE.md#part-5-first-deployment) for detailed deployment instructions.**

---

## Monitoring

### Automated Health Checks

Health checks run automatically **every 5 minutes** via GitHub Actions.

**View status:** [Actions → Health Check](https://github.com/iacosta3994/integration-glue-pipeline/actions/workflows/health-check.yml)

### Manual Health Check

```bash
# Check all services
npm run health-check

# Or via API
curl http://localhost:3000/health
```

### View Logs

```bash
# Application logs (Docker)
docker-compose logs -f

# Application logs (local)
cat logs/combined.log

# Error logs only
cat logs/error.log
```

### Sync History

View sync history in Supabase:

1. Open Supabase dashboard
2. Database → Tables → `sync_logs`
3. See all sync operations and their status

---

## Troubleshooting

### Common Issues

#### "Cannot connect to Supabase"
- ✅ Verify `SUPABASE_URL` and `SUPABASE_KEY` in `.env`
- ✅ Check project is not paused in Supabase dashboard
- ✅ Test connection: `curl -I $SUPABASE_URL`

#### "Notion integration not working"
- ✅ Verify database is shared with integration (most common issue!)
- ✅ Check `NOTION_DATABASE_ID` is correct (32 characters)
- ✅ Regenerate `NOTION_TOKEN` if expired

#### "Docker won't start"
- ✅ Ensure Docker Desktop is running
- ✅ Check port 3000 is not in use
- ✅ Try: `docker-compose down && docker-compose up --build`

#### "GitHub Actions failing"
- ✅ Verify all 11 required secrets are added
- ✅ Check secret names match exactly (case-sensitive)
- ✅ Re-run workflow after adding secrets

**More help:**
- 📖 [Full Troubleshooting Guide](./docs/TROUBLESHOOTING.md)
- 🔍 [Verification Guide](./VERIFICATION.md)
- 🐛 [Open an Issue](https://github.com/iacosta3994/integration-glue-pipeline/issues)

---

## Documentation

### 📖 Guides

- **[SETUP_GUIDE.md](./SETUP_GUIDE.md)** - Complete setup from scratch (60-90 minutes)
- **[CREDENTIALS.md](./CREDENTIALS.md)** - How to obtain all required credentials
- **[VERIFICATION.md](./VERIFICATION.md)** - Verify your setup is working correctly
- **[docs/TROUBLESHOOTING.md](./docs/TROUBLESHOOTING.md)** - Common issues and solutions

### 🔧 Scripts

- `npm start` - Start application
- `npm run dev` - Start with auto-reload
- `npm test` - Run tests
- `npm run health-check` - Verify all services
- `npm run lint` - Run ESLint
- `npm run migrate` - Run database migrations
- `npm run deploy` - Deploy to production

### 🐛 Issue Templates

When opening an issue, use the appropriate template:

- **Bug Report** - Something isn't working
- **Feature Request** - Suggest a new feature
- **Setup Help** - Need help with setup
- **Integration Issue** - Service integration problem

**[Open an Issue](https://github.com/iacosta3994/integration-glue-pipeline/issues/new/choose)**

---

## Development

### Local Development

```bash
# Start with hot-reload
npm run dev

# Or with Docker
docker-compose up
```

### Running Tests

```bash
# Run all tests
npm test

# Run with coverage
npm test -- --coverage

# Run linter
npm run lint
```

### Database Migrations

```bash
# Create new migration
supabase migration new migration_name

# Edit supabase/migrations/[timestamp]_migration_name.sql

# Apply migration
supabase db push
```

### Adding New Features

1. Create a feature branch
2. Make your changes
3. Add tests
4. Update documentation
5. Open a Pull Request

---

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

**Before submitting:**
- ✅ Run tests: `npm test`
- ✅ Run linter: `npm run lint`  
- ✅ Update documentation if needed
- ✅ Add tests for new features

---

## Architecture

### Data Flow

```
Supabase Database (PostgreSQL)
     ↓
     ↓ (REST API)
     ↓
Integration App (Node.js + Express)
     ↓
     ↓ (Notion API)
     ↓
Notion Database
```

### Components

- **Express Server** - HTTP endpoints for health checks and manual sync
- **Sync Service** - Fetches data from Supabase and pushes to Notion
- **Scheduler** - Cron jobs for automated hourly syncs
- **Logger** - Winston-based logging to console and files
- **Health Check** - Monitoring script for all services

### Technologies

- **Backend:** Node.js 18, Express  
- **Database:** Supabase (PostgreSQL)
- **Hosting:** Netlify
- **Integration:** Notion API
- **Containerization:** Docker & Docker Compose
- **CI/CD:** GitHub Actions
- **Infrastructure:** Terraform (AWS)
- **Logging:** Winston
- **Scheduling:** node-cron

---

## Security

### Best Practices

✅ **Never commit** `.env` files or credentials  
✅ **Use GitHub Secrets** for production credentials  
✅ **Rotate credentials** every 90 days  
✅ **Enable 2FA** on all service accounts  
✅ **Limit token scopes** to minimum required  
✅ **Review access logs** regularly  

### Credential Storage

- **Local development:** `.env` file (gitignored)
- **Production:** GitHub Secrets
- **Never:** Commit to version control

**See [CREDENTIALS.md](./CREDENTIALS.md#security-best-practices) for detailed security guidelines.**

---

## FAQ

### How often does data sync?

Automatically every hour via cron job. You can also trigger manual syncs.

### Can I change the sync schedule?

Yes! Edit `src/services/scheduler.js` and modify the cron expression.

### Does it work with multiple Notion databases?

Currently syncs to one database. You can modify the code to support multiple.

### Can I sync from Notion back to Supabase?

Not currently, but you can add this feature by creating a reverse sync service.

### Is this production-ready?

Yes! Includes error handling, logging, health checks, and automated testing.

### What if a sync fails?

Failures are logged to `sync_logs` table and error logs. Health checks will alert you.

---

## Roadmap

- [ ] Add unit and integration tests
- [ ] Support multiple Notion databases
- [ ] Bi-directional sync (Notion → Supabase)
- [ ] Web dashboard for monitoring
- [ ] Slack/email notifications
- [ ] Custom field mapping configuration
- [ ] Real-time sync with webhooks
- [ ] Multi-tenancy support

**Have ideas?** [Open a feature request](https://github.com/iacosta3994/integration-glue-pipeline/issues/new/choose)

---

## License

MIT License - see [LICENSE](./LICENSE) file for details.

---

## Support

### Getting Help

1. **Check documentation:**
   - [Setup Guide](./SETUP_GUIDE.md)
   - [Credentials Guide](./CREDENTIALS.md)
   - [Troubleshooting](./docs/TROUBLESHOOTING.md)

2. **Search existing issues:**
   - [Open Issues](https://github.com/iacosta3994/integration-glue-pipeline/issues)

3. **Open a new issue:**
   - [Bug Report](https://github.com/iacosta3994/integration-glue-pipeline/issues/new?template=bug_report.md)
   - [Setup Help](https://github.com/iacosta3994/integration-glue-pipeline/issues/new?template=setup_help.md)

### Contact

**Author:** Ian Acosta  
**Repository:** https://github.com/iacosta3994/integration-glue-pipeline  
**Issues:** https://github.com/iacosta3994/integration-glue-pipeline/issues

---

## Acknowledgments

- Built with [Supabase](https://supabase.com)
- Hosted on [Netlify](https://netlify.com)
- Integrated with [Notion](https://notion.so)
- Powered by [Node.js](https://nodejs.org)

---

**🎉 Ready to get started?**

1. Read [SETUP_GUIDE.md](./SETUP_GUIDE.md)
2. Follow the instructions
3. Deploy your integration!

**Questions?** [Open an issue](https://github.com/iacosta3994/integration-glue-pipeline/issues/new/choose)

---

<p align="center">
  <sub>Built with ❤️ by Ian Acosta</sub>
</p>
