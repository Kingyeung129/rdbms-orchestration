#!/bin/bash

# This is the entrypoint script for async-innodb-reload-server

exec sudo -E -u admin sg rsyncuser -c 'bash -c "/usr/local/bin/$RUST_BIN_NAME"'