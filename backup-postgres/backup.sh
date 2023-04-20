#!/bin/bash

# Backup jildini aniqlash
BACKUP_JILDI=/home/kube-user/backup-psql
# eski backuplarni o'chirish vaqti (kun hisobida)
BACKUP_OCHIRISH=5

# Backup jildini yaratish
mkdir /home/kube-user/backup-psql

# Hozirgi sana YYYY-MM-DD formatida olish
HOZIRGI_SANA=$(date +%Y-%m-%d)

# Backup global (roles va jadvallar)
#sudo -u postgres pg_dumpall --globals-only | gzip > $BACKUP_JILDI/postgres_globals_${HOZIRGI_SANA}.sql.gz

# Har bir ma'lumotlar bazasini backup olish
for db in `sudo -u postgres psql -t -c "select datname from pg_database where not datistemplate and datname != 'postgres'" | grep '\S' | awk '{$1=$1};1'`; do
   # Har bir ma'lumotlar bazasini dump qilish va compress qilish
   sudo -u postgres pg_dump $db | gzip > $BACKUP_JILDI/${db}_${HOZIRGI_SANA}.sql.gz
done

# Muvaffaqiyatli tugaganligini bildiruvchi xabar
echo "Backup muvaffaqiyatli amalga oshirildi. Backup fayllari $BACKUP_JILDI jildida saqlanadi."

# 5 kundan o'tgan backup nusxalarni o'chirish
find $BACKUP_JILDI -type f -name "*.sql.gz" -mtime +$BACKUP_OCHIRISH -exec rm {} \;

echo "Eski backuplar o'chirildi"
