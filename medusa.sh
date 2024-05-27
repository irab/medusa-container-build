#!/bin/sh

medusa migrations run

medusa user -e another-admin@example.com -p supersecret

medusa $1