## Postgresdagi databaselarni masofadan remote backup qilish

Ushbu shell script Postgresqldagi databaselarni masofadan(remote) yani local kompyuterdan o'zingizni kompyuteringizdan turib backup olish scripti. Script pg_dump bilan bita databaseni yani belgilangan databaseni backup(arxiv) qiladi.

```bash
# Server usernameni yozing
SERVER_USER=server
```
Bu yerda server usernamesini yozasiz agar server usernameni bilmasangiz `whoami` buyru oqali ko'rib olishingiz mumkin
```bash
whoami
```
Script Serverga ulanishi uchun Server IP adresini kiritishingiz kerak bo'lgan joy.
```bash
# Server IP adresini kiriting
# Server IP adresini olish $ ip a
SERVER_IP=192.168.1.165
```
Server IP adresini ko'rish

```bash
ip a
```
Postgresda backup qilmoqchi bo'lgan databaseyingizni nomini `database_nomi` o'rniga kiriting
```bash
# Postgresqldagi database nomini kiriting
DATABASE_NAME=database_nomi
```

Databselarni ko'rish

```bash
sudo su
su - postgress
psql
\l
```
Databse userini kiriting. Asosan default holda database useri postgres bo'ladi

```bash
# Database userini kiriting odatda postgres bo'ladi
DATABSE_USER=postgres
```

Databaseni yuklab olish uchun local yani o'zingizni qo'lizdagi kompyuterni userini kiritishingiz kerak bo'ladi

```bash
# Local o'zingizni kompyuteringiz userini kiriting
LOCAL_USER=ismoilovdev
```
Keyin kompyuteringizni IP addresini kiritishingiz kerak bo'ladi 

```bash
# O'zingizni kompyuteringizni IP adresini kiriting
LOCAL_IP=192.168.1.67
```

Local o'zingizni kompyuteringizda backup qilgan databaselarni saqlash uchun btta jild(papka folder) ochib olamiz.

```bash
# Kompyuteringizda backuplar qayerda turishini belgilang
# bu yerda avtomatik backup-psql jildida saqlanadi
LOCAL_BACKUP_DIR=~/backup-psql
```

Hammasi tayyor bo'lgandan keyin ishni script ishlaydi 

```bash
# Backuplar saqlanadigan jild ochish
mkdir -p $LOCAL_BACKUP_DIR

# Postgresql remote backup olish
pg_dump -h $SERVER_IP -p 5432 -Fc -U $DATABSE_USER $DATABASE_NAME > $LOCAL_BACKUP_DIR/$DATABASE_NAME-new_backup.dump
```