#!/usr/bin/env bash
set -euo pipefail
if [ -f .env ]; then export $(grep -v '^#' .env | xargs); fi
echo "Running: npx prisma db pull --schema=prisma/schema.prisma"
npx prisma db pull --schema=prisma/schema.prisma
echo "Running: npx prisma generate"
npx prisma generate
echo "Done."
