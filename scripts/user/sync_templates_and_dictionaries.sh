#!/bin/bash

log() {
  echo "$(date -u +'%Y-%m-%dT%H:%M:%S.%3NZ') [INFO] $*"
}

TEMPLATE_SRC="/lakehouse_templates"
DATA_DICT_SRC="/lakehouse_data_dictionaries"

for user_home in /home/*; do
    username=$(basename "$user_home")

    # Skip admin or root
    [[ "$username" == "admin" || "$username" == "root" ]] && continue

    user_template_dir="$user_home/csv_templates"
    mkdir -p "$user_template_dir"

    user_data_dict_dir="$user_home/data_dictionaries"
    mkdir -p "$user_data_dict_dir"

    # Sync files via rsync (delete and update)
    log "Syncing templates for user: $username"
    rsync -a --delete --chown="$username":"$username" "$TEMPLATE_SRC"/ "$user_template_dir"/

    log "Syncing data dictionaries for user: $username"
    rsync -a --delete --chown="$username":"$username" "$DATA_DICT_SRC"/ "$user_data_dict_dir"/
done

log "Sync completed for all available users."
