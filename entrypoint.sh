#!/bin/sh

npx medusa db:migrate

npx medusa user -e admin@example.com -p supersecret

npx medusa exec ./src/scripts/seed.ts

# Start the application and log output
yarn start > /app/server.log 2>&1