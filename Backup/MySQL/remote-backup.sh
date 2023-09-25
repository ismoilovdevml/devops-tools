#!/bin/bash

SERVER_USER=dev-db-user
SERVER_IP=172.168.1.167
DATABASE_NAME=database_name
DATABASE_USER=root # change to your MySQL user
DATABASE_PASSWORD=your_password # change to your MySQL password

LOCAL_USER=user

LOCAL_IP=192.168.1.46

LOCAL_BACKUP_DIR=/home/user/backups/mysql

CURRENT_DATETIME=$(date "+%Y-%m-%d_%H-%M-%S")

mkdir -p $LOCAL_BACKUP_DIR

# Use mysqldump to create a backup
mysqldump -h $SERVER_IP -u $DATABASE_USER -p$DATABASE_PASSWORD $DATABASE_NAME > $LOCAL_BACKUP_DIR/${DATABASE_NAME}_dev_${CURRENT_DATETIME}-new_backup.sql
