#!/bin/bash
set -euo pipefail

# Dumps a database from a remote MySQL server down to this machine.
# Override any of these with environment variables instead of editing the file.
SERVER_IP="${SERVER_IP:-172.168.1.167}"
DATABASE_NAME="${DATABASE_NAME:-database_name}"
DATABASE_USER="${DATABASE_USER:-root}"

# Passing the password as `-p$PASSWORD` puts it in the process list, where any
# local user can read it with `ps`. MYSQL_PWD is passed through the environment
# of the mysqldump process only.
DATABASE_PASSWORD="${DATABASE_PASSWORD:?Set DATABASE_PASSWORD in the environment}"

LOCAL_BACKUP_DIR="${LOCAL_BACKUP_DIR:-/home/user/backups/mysql}"

CURRENT_DATETIME=$(date "+%Y-%m-%d_%H-%M-%S")

mkdir -p "$LOCAL_BACKUP_DIR"

outfile="${LOCAL_BACKUP_DIR}/${DATABASE_NAME}_dev_${CURRENT_DATETIME}-new_backup.sql"

MYSQL_PWD="$DATABASE_PASSWORD" mysqldump \
    -h "$SERVER_IP" \
    -u "$DATABASE_USER" \
    "$DATABASE_NAME" > "$outfile"

echo "Backup written to $outfile"
