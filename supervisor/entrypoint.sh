#!/bin/bash

TEMPLATE_CONF="/etc/supervisor/supervisord.conf.tpl"
SUPERVISOR_CONF="/etc/supervisor/supervisord.conf"

echo "[INFO] Generating supervisord.conf with environment..."

# Escape % for supervisor config
ESCAPED_FILE_SUFFIX="${FILE_SUFFIX//%/%%}"

ENV_VARS="SOURCE_DIR=\"$SOURCE_DIR\",DEST_USER=\"$DEST_USER\",DEST_HOST=\"$DEST_HOST\",DEST_DIR=\"$DEST_DIR\",TEMPLATE_DIR=\"$TEMPLATE_DIR\",FILE_SUFFIX=\"$ESCAPED_FILE_SUFFIX\",CSV_EVENT_WAIT_SECONDS=\"$CSV_EVENT_WAIT_SECONDS\",CSV_EVENT_UPPER_LIMIT=\"$CSV_EVENT_UPPER_LIMIT\""

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

exec /usr/bin/supervisord -c "$SUPERVISOR_CONF"
