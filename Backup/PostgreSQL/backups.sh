#!/bin/bash
set -euo pipefail

BACKUP_ROOT="${BACKUP_ROOT:-/home/user/backups}"

databases=$(sudo -u postgres psql -t -A -c \
    "select datname from pg_database WHERE datname <> ALL ('{template0,template1,postgres}')")

while IFS= read -r db_name; do
    [ -n "$db_name" ] || continue

    backup_file=$(date +'%Y-%m-%d-%H-%M-%S')
    backup_dir="${BACKUP_ROOT}/${db_name}"

    echo "$backup_dir"
    mkdir -p "$backup_dir"

    sudo -u postgres pg_dump "$db_name" > "${backup_dir}/${backup_file}.sql"
done <<< "$databases"
