#!/bin/bash

# Set yarn to new version so dlx works

yarn set version berry  

# Build the Medusa server image
 if [ ! -d "medusa" ]; then
    yarn dlx @medusajs/medusa-cli@1.3.22 new --useDefaults medusa --skip-db
fi
# # Run the Medusa server

docker compose build

docker compose up