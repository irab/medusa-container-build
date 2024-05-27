# Building Medusa images for production and development use

Four core components are required for a full Medusa deployment:

- Admin UI
- Backend API
- A Frontend
- A Postgres instance with an initialised DB

## Prerequisites and environment setup

You need to have yarn install correctly. On Debian Bookworm ensure:

1. `sudo apt install nodejs npm`
1. `corepack enable`
1. `yarn set version berry`

This will ensure you're running the latest version of yarn (>= 4.2.2)

## Build Steps

Start by:

1. Cloning this repo, which should is just a few Dockerfiles and a docker-compose.yml
1. Running `yarn dlx @medusajs/medusa-cli@1.3.22 new --useDefaults medusa --skip-db` 
1. 

### Admin Build

