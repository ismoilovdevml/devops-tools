#!/bin/bash
echo -n "Enter the MySQL root password: "
read -s root_password
echo

# Check the password by trying to access MySQL
mysql -u root -p${root_password} -e "exit"
if [ $? -ne 0 ]; then
    echo "Invalid password. Exiting."
    exit 1
fi

# Get the list of databases, excluding the system databases
databases=$(mysql -u root -p${root_password} -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql|sys)")

for db_name in $databases
do
    backup_file=$(date +'%Y-%m-%d-%H-%M-%S')
    backup_dir="/home/ismoilovdevarchlinux/3backup-mysql/${db_name}/"
    echo $backup_dir
    if [ ! -d $backup_dir ]; then
        mkdir -p $backup_dir
    fi
    # Dump each database in a separate file
    mysqldump -u root -p${root_password} $db_name > "${backup_dir}${backup_file}.sql"
done