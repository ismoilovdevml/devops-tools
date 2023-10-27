#!/bin/bash

# Colors for terminal output
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT_GRAY='\033[0;37m'
DARK_GRAY='\033[1;30m'
LIGHT_RED='\033[1;31m'
LIGHT_GREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHT_BLUE='\033[1;34m'
LIGHT_PURPLE='\033[1;35m'
LIGHT_CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m' 

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
echo "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo "${LIGHT_GREEN}"
cat << "EOF"
 $$$$$$\  $$\   $$\     $$\           $$\             $$$$$$\                       $$\               $$\ $$\                     
$$  __$$\ \__|  $$ |    $$ |          $$ |            \_$$  _|                      $$ |              $$ |$$ |                    
$$ /  \__|$$\ $$$$$$\   $$ | $$$$$$\  $$$$$$$\          $$ |  $$$$$$$\   $$$$$$$\ $$$$$$\    $$$$$$\  $$ |$$ | $$$$$$\   $$$$$$\  
$$ |$$$$\ $$ |\_$$  _|  $$ | \____$$\ $$  __$$\         $$ |  $$  __$$\ $$  _____|\_$$  _|   \____$$\ $$ |$$ |$$  __$$\ $$  __$$\ 
$$ |\_$$ |$$ |  $$ |    $$ | $$$$$$$ |$$ |  $$ |        $$ |  $$ |  $$ |\$$$$$$\    $$ |     $$$$$$$ |$$ |$$ |$$$$$$$$ |$$ |  \__|
$$ |  $$ |$$ |  $$ |$$\ $$ |$$  __$$ |$$ |  $$ |        $$ |  $$ |  $$ | \____$$\   $$ |$$\ $$  __$$ |$$ |$$ |$$   ____|$$ |      
\$$$$$$  |$$ |  \$$$$  |$$ |\$$$$$$$ |$$$$$$$  |      $$$$$$\ $$ |  $$ |$$$$$$$  |  \$$$$  |\$$$$$$$ |$$ |$$ |\$$$$$$$\ $$ |      
 \______/ \__|   \____/ \__| \_______|\_______/       \______|\__|  \__|\_______/    \____/  \_______|\__|\__| \_______|\__|      
                                                                                                                             
EOF
echo "${NC}"
echo "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"

echo "${GREEN}Enter the domain for your GitLab instance: ${YELLOW}"
read domain

echo "${GREEN}Enter the server IP address for proxy configuration: ${YELLOW}"
read server_ip

echo "${GREEN}Enter the desired password for the GitLab root user: ${YELLOW}"
read root_password


echo -e "${LIGHT_GREEN}Updating system packages...${NC}"
echo -e "${LIGHT_BLUE}"
apt-get update && apt-get upgrade
echo -e "${NC}"

echo -e "${LIGHT_GREEN}Installing necessary dependencies...${NC}"
echo -e "${LIGHT_BLUE}"
apt-get install -y curl openssh-server ca-certificates tzdata perl git htop zip unzip 
echo -e "${NC}"

echo -e "${LIGHT_GREEN}Installing Postfix...${NC}"
echo -e "${LIGHT_BLUE}"
DEBIAN_FRONTEND=noninteractive apt-get install -y postfix
echo -e "${NC}"

echo -e "${LIGHT_GREEN}Adding GitLab package repository...${NC}"
echo -e "${LIGHT_BLUE}"
curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | bash
echo -e "${NC}"

echo "Installing GitLab..."
echo -e "${LIGHT_BLUE}"
EXTERNAL_URL="http://${domain}" apt-get install -y gitlab-ee
echo -e "${NC}"

echo -e "${LIGHT_GREEN}Configuring GitLab...${NC}"
echo -e "${LIGHT_BLUE}"
gitlab-ctl reconfigure
echo -e "${NC}"

echo -e "${LIGHT_GREEN}Setting root password...${NC}"
echo -e "${LIGHT_BLUE}"
gitlab-rails runner "user = User.where(id: 1).first; user.password = '${root_password}'; user.password_confirmation = '${root_password}'; user.save!"
echo -e "${NC}"

echo -e "${LIGHT_GREEN}Installing and configuring Nginx..."
apt-get install -y nginx

if [ -f /etc/nginx/sites-available/${domain} ]; then
    echo -e "${LIGHT_GREEN}Nginx configuration for ${domain} already exists.${NC}"
else
    cat > /etc/nginx/sites-available/${domain} <<EOF
server {
    listen 80;
    server_name ${domain};

    # Redirect HTTP to HTTPS
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name ${domain};

    ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
    ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;

    location / {
        proxy_pass http://${server_ip};
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

    ln -sf /etc/nginx/sites-available/${domain} /etc/nginx/sites-enabled/${domain}
    nginx -t && systemctl reload nginx
    echo "Nginx configured successfully for ${domain}."
fi

echo -e "${LIGHT_GREEN}GitLab Version:${NC}"
gitlab-rake gitlab:env:info | grep "GitLab version"

echo -e "${LIGHT_GREEN}Installation and configuration complete.${NC}"
echo -e "${LIGHT_GREEN}You can access GitLab at https://${domain}${NC}"
echo -e "${LIGHT_GREEN}Login with the username 'root' and the password you set.${NC}"