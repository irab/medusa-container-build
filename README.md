# Building containerised Medusa images for production and development use

Four core components are required for a full Medusa deployment:

- Admin UI
- Backend Server running Store and Admin APIs
- A Redis instance as an Eventbus
- A Postgres instance with an initialised DB
- TODO: Add a frontend of some sort


This is a work in progress and "works on my machine" and has not been tested on any other system.

## Prerequisites and environment setup

You need to have yarn install correctly. On Debian Bookworm ensure:

1. [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed
1. `sudo apt install nodejs npm` - probably some other things as well??
1. `yarn set version berry` - Berry is needed to run `dlx` command. Classic is needed in the containers.


## Build Steps

Run [build.sh](./build.sh), which uses the medusa-cli tool (version pinned) to install the `medusa` directory, builds the Backend and Admin images and runs them with `docker compose up`.

Medusa could be run off the same image and container but I'm trying to them running seperately so I've got different medusa-config.js files for each to test a few things.

## Accessing Admin and API Endpoints

**Admin Dashboard:** http://localhost:7001/adminapp/ - the admin user and password is created in [medusa.sh](./medusa.sh)

**API endpoint:** http://localhost:9000

Test the API endpoint with something like this `curl --location 'http://localhost:9000/store/products' --header 'Accept: application/json' | jq` (assuming you have jq installed)

## Troubleshooting

Note that the Admin image is built from node:lts which has `/bin/bash` installed and the backend image is build from alpine, which has `/bin/sh` as the default shell.

```bash
# Exec into the admin container
docker compose exec backend /bin/bash

# Exec into the backend container
docker compose exec backend /bin/sh
```

Note: Postgres database state is running in Docker. Don't expect it to exist after the container is stopped.


Unsure what version of Medusa is actually installed by `medusa-cli`, as this is does not seem configurable?! :unamused: