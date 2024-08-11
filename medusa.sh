!/bin/sh

medusa migrations run

medusa seed -f seed.json

medusa user -e another-admin@example.com -p supersecret

medusa $1