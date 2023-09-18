#/bin/bash

tables=$( sudo -u postgres psql -t -c "select datname from pg_database WHERE datname <> ALL ('{template0,template1,postgres}')")

for table_name in $(echo $tables | tr " " "\n")
do
        backup_file=$(date +'%Y-%m-%d-%H-%M-%S')
        backup_dir="/home/user/backups/${table_name}/"
        echo $backup_dir
        if [ ! -d $backup_dir ]; then
                mkdir -p $backup_dir
        fi
        sudo -u postgres pg_dump $table_name > "${backup_dir}${backup_file}.sql"
done