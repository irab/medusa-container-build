#!/bin/sh

npx medusa db:migrate

npx medusa user -e $ADMIN_EMAIL -p $ADMIN_PASSWORD

npx medusa exec ./src/scripts/seed.ts

# Start the application and log output
yarn start > /app/server.log 2>&1