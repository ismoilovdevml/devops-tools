## Install and configure Mifos X(Fineract) 

```bash
sudo apt-get update && sudo apt-get upgrade -y
git clone https://github.com/apache/fineract.git
sudo apt install openjdk-17-jdk openjdk-17-jre
```

### MariaDB Installation
```bash
sudo apt update -y
curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash
sudo apt-get install mariadb-server mariadb-client -y
```
### Time Zone
```bash
serverTimezone=UTC&useLegacyDatetimeCode=false&sessionVariables=time_zone=‘-00:00’
```

### Tomcat 9 Installation

[How to Install Tomcat 9 on Ubuntu 20.04](https://vegastack.com/tutorials/how-to-install-tomcat-9-on-ubuntu-20-04/)


```bash
sudo apt install openjdk-11-jdk
sudo useradd -m -U -d /opt/tomcat -s /bin/false tomcat
cd /tmp
VERSION=9.0.82
wget https://downloads.apache.org/tomcat/tomcat-9/v${VERSION}/bin/apache-tomcat-${VERSION}.tar.gz
sudo tar -xf /tmp/apache-tomcat-${VERSION}.tar.gz -C /opt/tomcat/
sudo ln -s /opt/tomcat/apache-tomcat-${VERSION} /opt/tomcat/latest
sudo chown -R tomcat: /opt/tomcat
sudo sh -c 'chmod +x /opt/tomcat/latest/bin/*.sh'
sudo nano /etc/systemd/system/tomcat.service
```

```service
/etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat 9 servlet container
After=network.target
[Service]
Type=forking
User=tomcat
Group=tomcat
Environment="JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom -Djava.awt.headless=true"
Environment="CATALINA_BASE=/opt/tomcat/latest"
Environment="CATALINA_HOME=/opt/tomcat/latest"
Environment="CATALINA_PID=/opt/tomcat/latest/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
ExecStart=/opt/tomcat/latest/bin/startup.sh
ExecStop=/opt/tomcat/latest/bin/shutdown.sh
[Install]
WantedBy=multi-user.target
```
```bash
sudo systemctl daemon-reload
sudo systemctl enable tomcat
sudo systemctl start tomcat
sudo systemctl stop tomcat
sudo systemctl restart tomcat
```

[Stackowerflow link](https://stackoverflow.com/questions/36703856/access-tomcat-manager-app-from-different-host)