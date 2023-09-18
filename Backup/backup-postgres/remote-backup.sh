#!/bin/bash

SERVER_USER=dev-db-user
SERVER_IP=172.168.1.167
DATABASE_NAME=new_database
DATABASE_USER=postgres

LOCAL_USER=ismoilovdev

LOCAL_IP=192.168.1.46

LOCAL_BACKUP_DIR=/home/ismoilovdev/Remote-backups

CURRENT_DATETIME=$(date "+%Y-%m-%d_%H-%M-%S")

mkdir -p $LOCAL_BACKUP_DIR

pg_dump -h $SERVER_IP -p 5432 -Fc -U $DATABASE_USER $DATABASE_NAME > $LOCAL_BACKUP_DIR/${DATABASE_NAME}_dev_${CURRENT_DATETIME}-new_backup.dump
