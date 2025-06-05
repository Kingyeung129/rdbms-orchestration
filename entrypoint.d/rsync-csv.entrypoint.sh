#!/bin/bash

# This is the entrypoint script for rsync-csv
echo "Entry point script for rsync-csv"

TEMPLATE_CONF="/etc/supervisor/supervisord.conf.tpl"
SUPERVISOR_CONF="/etc/supervisor/supervisord.conf"

# Generate supervisord.conf with environment variables
echo "[INFO] Generating supervisord.conf with environment..."

# Escape % for supervisor config
ESCAPED_FILE_SUFFIX="${FILE_SUFFIX//%/%%}"

ENV_VARS=$(
    printf 'SOURCE_DIR="%s",' "$SOURCE_DIR"
    printf 'DEST_USER="%s",' "$DEST_USER"
    printf 'DEST_HOST="%s",' "$DEST_HOST"
    printf 'DEST_DIR="%s",' "$DEST_DIR"
    printf 'TEMPLATE_DIR="%s",' "$TEMPLATE_DIR"
    printf 'FILE_SUFFIX="%s",' "$ESCAPED_FILE_SUFFIX"
    printf 'CSV_EVENT_WAIT_SECONDS="%s",' "$CSV_EVENT_WAIT_SECONDS"
    printf 'CSV_EVENT_UPPER_LIMIT="%s"' "$CSV_EVENT_UPPER_LIMIT"
)

cp "$TEMPLATE_CONF" "$SUPERVISOR_CONF"

# Inject env into the rsync_csv program block
awk -v envs="$ENV_VARS" '
    BEGIN { done=0 }
    {
        print
        if (!done && $0 ~ /^\[program:rsync_csv\]/) {
            getline; print $0
            print "environment=" envs
            done=1
        }
    }
' "$TEMPLATE_CONF" > "$SUPERVISOR_CONF"

# Add admin user to supervisord config
echo "[INFO] Adding user to supervisord config..."
echo "user=$REMOTE_SSH_USERNAME" >> "$SUPERVISOR_CONF"

# Add ssh host key
echo "[INFO] Adding $DEST_HOST SSH host key to known_hosts..."
ssh-keyscan -H $DEST_HOST >> ~/.ssh/known_hosts

# Start cron service
echo "[INFO] Starting cron service for sync templates and dictionaries..."
sudo chmod +x /usr/local/bin/sync_templates_and_dictionaries.sh
sudo service cron start

# Start supervisord
echo "[INFO] Starting supervisord with config: $SUPERVISOR_CONF"
exec /usr/bin/supervisord -c "$SUPERVISOR_CONF"
