#!/bin/bash
set -euo pipefail

BACKUP_ROOT="${BACKUP_ROOT:-/home/ismoilovdevarchlinux/3backup-mysql}"

echo -n "Enter the MySQL root password: "
read -rs root_password
echo

# Export instead of passing -p"$root_password" on the command line: arguments are
# visible to every local user via `ps`, the environment of a single process is not.
export MYSQL_PWD="$root_password"

# Check the password by trying to access MySQL.
if ! mysql -u root -e "exit" 2>/dev/null; then
    echo "Invalid password. Exiting." >&2
    exit 1
fi

# Get the list of databases, excluding the system databases.
databases=$(mysql -u root -N -B -e "SHOW DATABASES;" \
    | grep -Ev "^(information_schema|performance_schema|mysql|sys)$")

for db_name in $databases
do
    backup_file=$(date +'%Y-%m-%d-%H-%M-%S')
    backup_dir="${BACKUP_ROOT}/${db_name}"

    echo "$backup_dir"
    mkdir -p "$backup_dir"

    # Dump each database in a separate file.
    mysqldump -u root "$db_name" > "${backup_dir}/${backup_file}.sql"
done
