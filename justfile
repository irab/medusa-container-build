# List available commands
default:
    @just --list

# Start core backend services (postgres, redis, medusa_server, medusa_worker, create_api)
backend:
    docker compose -f docker-compose-v2.yml --profile backend up -d
    @echo "Waiting for backend services to be ready..."
    @echo "Watching create_api logs for bootstrap completion..."
    docker compose -f docker-compose-v2.yml logs -f create_api

# Start frontend with all required backend services
# (automatically starts postgres, redis, medusa_server, medusa_worker, create_api)
frontend: backend
    @echo "Backend is ready, starting frontend..."
    docker compose -f docker-compose-v2.yml --profile frontend up -d

# Start everything (equivalent to running both backend and frontend profiles)
start: frontend
    @echo "All services are up and running"

# Start an interactive development environment for the storefront
dev:
    @echo "Starting storefront in development mode..."
    docker compose -f docker-compose-v2.yml --profile dev up -d

# Watch for changes
watch:
    docker compose -f docker-compose-v2.yml watch

# View logs
logs:
    docker compose -f docker-compose-v2.yml logs -f

# Stop all services
down:
    docker compose -f docker-compose-v2.yml down

# Clean everything
clean:
    docker compose -f docker-compose-v2.yml down -v
    docker system prune -f

# Build all containers without starting them
build-dev-storefront:
    docker compose -f docker-compose-v2.yml build dev-storefront

# Rebuild and restart the server and worker containers
rebuild-backend:
    docker compose -f docker-compose-v2.yml --profile backend down -v
    docker system prune -f
    docker compose -f docker-compose-v2.yml --profile backend up -d --force-recreate