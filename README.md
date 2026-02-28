# Integration Glue Pipeline

> A comprehensive integration pipeline connecting Netlify, Supabase, and Notion with automated deployment, database migrations, and health monitoring.

## Overview

This project provides a robust integration layer that connects multiple services:
- **Netlify**: Frontend hosting and deployment
- **Supabase**: Backend database and authentication
- **Notion**: Content management and documentation

## Features

- 🚀 Automated CI/CD pipeline with GitHub Actions
- 🐳 Docker containerization for consistent environments
- 🗄️ Database migration management
- 📊 Health monitoring and status checks
- ☁️ Infrastructure as Code with Terraform
- 🔄 Automated Notion database sync

## Prerequisites

- Node.js 18+ 
- Docker & Docker Compose
- Terraform 1.0+
- GitHub account
- Netlify account
- Supabase project
- Notion workspace

## Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/iacosta3994/integration-glue-pipeline.git
cd integration-glue-pipeline
```

### 2. Install dependencies

```bash
npm install
```

### 3. Configure environment variables

```bash
cp .env.example .env
# Edit .env with your credentials
```

### 4. Start local development

```bash
docker-compose up
```

## Project Structure

```
.
├── .github/workflows/      # GitHub Actions workflows
│   ├── ci-cd.yml          # Main CI/CD pipeline
│   ├── deploy-netlify.yml # Netlify deployment
│   ├── migrate-supabase.yml # Database migrations
│   ├── setup-notion.yml   # Notion configuration
│   └── health-check.yml   # Monitoring
├── src/                   # Application source code
├── terraform/             # Infrastructure as Code
├── docker/                # Docker configurations
├── scripts/               # Automation scripts
├── supabase/             # Database migrations
├── docker-compose.yml    # Local development setup
├── Dockerfile            # Container definition
├── netlify.toml          # Netlify configuration
└── package.json          # Node.js dependencies
```

## Deployment

Deployment is automated through GitHub Actions. Push to the `main` branch to trigger:

1. Build and test
2. Database migrations
3. Netlify deployment
4. Notion sync
5. Health checks

## Environment Variables

See `.env.example` for all required configuration variables.

## Monitoring

Health checks run every 5 minutes to ensure all services are operational. Check the Actions tab for status.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

MIT License - see LICENSE file for details

## Author

Ian Acosta
