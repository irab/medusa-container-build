#!/bin/bash

# Set yarn to use berry version for speed  
yarn set version berry 

rm -rf medusa

# Stop and remove postgres container

docker stop $(docker ps -a -q --filter=name=postgres-medusa)
docker rm $(docker ps -a -q --filter=name=postgres-medusa)
docker run -d -p 5432:5432 --name postgres-medusa -e POSTGRES_PASSWORD=medusa postgres

# Create subshell to feed input to yarn create create-medusa-app

{
echo "medusa"
sleep 4
echo "N"
sleep 1
echo "postgres"
sleep 1
echo "medusa"
sleep 1
echo "postgres"
} | yarn create create-medusa-app \
--repo-url "--depth=1 https://github.com/medusajs/medusa-starter-default" \
--seed \
--no-browser \
--verbose

cp medusa/.env .

rm -rf medusa
git clone -b feat/v2 --depth=1 https://github.com/medusajs/medusa-starter-default medusa

# Install dependencies, build and start server

cd medusa
yarn install
yarn build
cp ../.env .medusa/server

# Run built version of Medusa
cd .medusa/server
yarn install
npx medusa user --email admin@example.com --password admin
yarn run start
