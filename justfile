# List available commands
default:
    @just --list

# Start core backend services (postgres, redis, medusa_server, medusa_worker, bootstrap)
backend:
    docker compose -f docker-compose-v2.yml --profile backend up -d
    @echo "Waiting for backend services to be ready..."
    @docker compose -f docker-compose-v2.yml logs -f bootstrap | grep -q "Bootstrap process complete"

# Start frontend with all required backend services
# (automatically starts postgres, redis, medusa_server, medusa_worker, bootstrap)
frontend: backend
    @echo "Backend is ready, starting frontend..."
    docker compose -f docker-compose-v2.yml --profile frontend up -d

# Start everything (equivalent to running both backend and frontend profiles)
all: frontend
    @echo "All services are up and running"

# Start an interactive development environment for the storefront
dev:
    @echo "Starting storefront in development mode..."
    docker compose -f docker-compose-v2.yml --profile dev up

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
build:
    docker compose -f docker-compose-v2.yml --profile all build 