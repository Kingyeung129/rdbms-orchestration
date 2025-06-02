#!/bin/bash
# Check if figlet is installed
if ! command -v figlet &> /dev/null; then
    echo "figlet not found. Installing..."

    # Determine package manager and install
    if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y figlet
    elif command -v yum &> /dev/null; then
        sudo yum install -y figlet
    elif command -v pacman &> /dev/null; then
        sudo pacman -Sy --noconfirm figlet
    else
        echo "Unsupported package manager. Install figlet manually."
        exit 1
    fi
fi

# Run figlet with slant font
figlet -f slant RDBMS

# Check if any of the test containers exist
if docker ps -a --format '{{.Names}}' | grep -E '^(rdbms-rsync-csv|rdbms-async-innodb-reload-server)$' > /dev/null; then
  docker compose down -v
fi

export $(grep -v '^#' .env | xargs)
docker compose up --build