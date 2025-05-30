#!/bin/bash
# Check if any of the test containers exist
if docker ps -a --format '{{.Names}}' | grep -E '^(rdbms-rsync-csv|rdbms-async-innodb-reload-server)$' > /dev/null; then
  docker compose down -v
fi

export $(grep -v '^#' .env | xargs)
docker compose up --build