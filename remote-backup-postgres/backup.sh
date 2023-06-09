#!/bin/bash

# Server usernameni yozing
SERVER_USER=server
# Server IP adresini kiriting
# Server IP adresini olish $ ip a
SERVER_IP=192.168.1.165
# Postgresqldagi database nomini kiriting
DATABASE_NAME=database_nomi
# Database userini kiriting odatda postgres bo'ladi
DATABSE_USER=postgres

# Local o'zingizni kompyuteringiz userini kiriting
LOCAL_USER=ismoilovdev
# O'zingizni kompyuteringizni IP adresini kiriting
LOCAL_IP=192.168.1.67
# Kompyuteringizda backuplar qayerda turishini belgilang
# bu yerda avtomatik backup-psql jildida saqlanadi
LOCAL_BACKUP_DIR=~/backup-psql

# Olingan database backup nomiga qachon olinganini yoizb qo'yadi yil oy kun soat minut sekund
CURRENT_DATETIME=$(date "+%Y-%m-%d_%H-%M-%S")

# Backuplar saqlanadigan jild ochish
mkdir -p $LOCAL_BACKUP_DIR

# Postgresql remote backup olish

# .dump qilib olish uchun
# pg_dump -h $SERVER_IP -p 5432 -Fc -U $DATABSE_USER $DATABASE_NAME > $LOCAL_BACKUP_DIR/${DATABASE_NAME}_${CURRENT_DATETIME}-new_backup.dump
# .sql qilib olish uchun
pg_dump -h $SERVER_IP -p 5432 -Fc -U $DATABSE_USER $DATABASE_NAME > $LOCAL_BACKUP_DIR/${DATABASE_NAME}_${CURRENT_DATETIME}-new_backup.sql