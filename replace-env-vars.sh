#!/bin/sh

# This is the server address used during the frontend build process.
MEDUSA_SERVER_BUILD_TIME="127.0.0.1:9000"
# This is the server address used at runtime inside the container.
MEDUSA_SERVER_RUN_TIME="medusa_server:9000"  # container's address

# Set the NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY environment variable
export NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=$(cat /api_key/api_key)

# Replace the build-time server address with the runtime server address in all files
# in the ./public and ./.next directories.
find ./public ./.next -type f -name "*.*" |
while read file; do
    sed -i "s|$MEDUSA_SERVER_BUILD_TIME|$MEDUSA_SERVER_RUN_TIME|g" "$file"
done