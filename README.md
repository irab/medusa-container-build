# Medusa Container Build

This repository contains Docker configurations for running Medusa e-commerce in containers, supporting both production and development environments.

## Components

The setup includes the following core components:
- Medusa Server (Store API, Admin API, and Admin UI)
- Medusa Worker (Event processing)
- Next.js Storefront
- PostgreSQL database
- Redis for event bus
- API key bootstrap service

## Build Process & Scripts

The build process involves several key scripts that handle initialization and setup:

### Server Initialization (`entrypoint.sh`)
The Medusa server container uses an entrypoint script that:
1. Runs database migrations
2. Creates the admin user using environment variables
3. Seeds initial data
4. Starts the Medusa server with logging

### API Key Creation (`create-publishable-key.sh`)
A dedicated service handles the creation of the Publishable API key required by the storefront:
1. Authenticates with the Medusa server
2. Creates or retrieves a publishable API key
3. Associates the key with the default sales channel
4. Makes the key available to the storefront container

### Environment Variable Management (`replace-env-vars.sh`)
The storefront build process uses a script to handle environment variables:
1. Injects the generated publishable API key from the mounted volume
2. Replaces build-time server addresses with runtime container addresses
3. Updates all necessary files in the Next.js build output

### Build Flow
1. Backend services (PostgreSQL, Redis) start first
2. Medusa server initializes and becomes healthy
3. API key creation service runs and generates necessary credentials
4. Storefront builds and starts with the generated API key
5. Environment variables are replaced for container networking

## Prerequisites

1. [Docker](https://www.docker.com/products/docker-desktop/) installed and running
2. [just](https://just.systems/man/en/) command runner installed
3. Required environment variables set (copy from `.env.template`)

## Quick Start Commands

All commands are managed through the `just` command runner:

```bash
# Start only backend services (postgres, redis, medusa_server, medusa_worker)
just backend

# Start production frontend with all required backend services
just frontend

# Start everything in production mode
just start

# Start development environment for the storefront
just dev

# View logs from all services
just logs

# Stop all services
just down

# Clean everything (including volumes)
just clean

# Build all containers without starting them
just build

# Rebuild and restart only the server components
just rebuild-server
```

## Service URLs

- **Storefront:** http://localhost:8000
- **Admin Dashboard:** http://localhost:9000/app
- **Store API:** http://localhost:9000/store/*
- **Admin API:** http://localhost:9000/admin/*

## Development vs Production

The setup supports two modes:

### Production Mode
Uses `just frontend` or `just all` which:
- Builds optimized production containers
- Runs the storefront in production mode
- Minimal debug output
- Optimized for performance

### Development Mode
Uses `just dev` which:
- Enables hot-reloading for the storefront
- Mounts source code for live editing
- Provides detailed debug output
- Optimized for development experience

## Troubleshooting

If you encounter issues:

1. Check logs with `just logs`
2. Ensure all required environment variables are set
3. Try cleaning the environment with `just clean` and restart
4. Verify all services are healthy with `docker compose -f docker-compose-v2.yml ps`

For database or service issues:
```bash
# Reset everything and remove volumes
just clean

# Rebuild all services
just build

# Start services again
just all
```

## Container Shell Access

```bash
# Access Medusa server container
docker compose -f docker-compose-v2.yml exec medusa_server sh

# Access PostgreSQL container
docker compose -f docker-compose-v2.yml exec postgres bash
```

