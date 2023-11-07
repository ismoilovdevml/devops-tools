## Setup Mifos X (Apache Fineract)

## Installing System Updates and Prerequisites

```bash
sudo apt-get update && sudo apt upgrade -y
sudo apt install openjdk-17-jdk openjdk-17-jre zip unzip 
sudo apt-get update
```

## Install MySQL server
```bash
sudo apt install mysql-server
sudo mysql_secure_installation
sudo mysql
ALTER USER 'root'@'34.136.231.76' IDENTIFIED WITH mysql_native_password BY 'mysql';
FLUSH PRIVILEGES;
exit
mysql -u root -p
create database `mifosplatform-tenants`;
create database `mifostenant-default`;
show databses;
```

## Tomcat

```bash
wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.82/bin/apache-tomcat-9.0.82.tar.gz
tar -xvf apache-tomcat-9.0.82.tar.gz
sudo su
cp -r tomcat-9/ /usr/share/
sudo nano .bashrc
export CATALINA_HOME=/usr/share/tomcat-9
source ~/.bashrc
```

## Enable SSL

```bash
sudo keytool -genkey -keyalg RSA -alias tomcat -keystore /usr/share/tomcat.keystore
sudo nano /usr/share/tomcat-9/conf/server.xml
```

### Download drizzle jdbc connector

```bash
cd /usr/share/tomcat-9/lib
```

### TIME ZONE

```bash
serverTimezone=UTC&useLegacyDatetimeCode=false&sessionVariables=time_zone=‘-00:00’
```

### Fineract

```bash
git clone https://github.com/apache/fineract.git
cd fineract
./gradlew createDB -PdbName=fineract_tenants
./gradlew createDB -PdbName=fineract_default
./gradlew bootRun
```

https://34.136.231.76:8443/fineract-provider/
https://34.136.231.76:8443/fineract-provider/actuator/health
http://34.136.231.76:9090/?baseApiUrl=https://34.136.231.76:8443/fineract-provider&tenantIdentifier=default