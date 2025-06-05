#!/bin/bash

# This is the entrypoint script for async-innodb-reload-server
echo "Entry point script for async-innodb-reload-server"

exec sg rsyncusers -c "/usr/local/bin/$RUST_BIN_NAME"