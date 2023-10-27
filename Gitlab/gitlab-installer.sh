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
                   
echo "${GREEN}Enter the domain for your GitLab instance: ${YELLOW}"
read gitlab_domain

echo "${GREEN}Enter the desired password for the GitLab root user: ${YELLOW}"
read root_password


echo -e "${LIGHT_GREEN}Updating system packages...${NC}"
echo -e "${LIGHT_BLUE}"
apt-get update -y
apt-get upgrade -y
echo -e "${NC}"

echo -e "${LIGHT_GREEN}Installing necessary dependencies...${NC}"
echo -e "${LIGHT_BLUE}"
apt-get install -y curl openssh-server ca-certificates tzdata perl
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
EXTERNAL_URL="http://${gitlab_domain}" apt-get install -y gitlab-ee
echo -e "${NC}"

echo -e "${LIGHT_GREEN}Configuring GitLab...${NC}"
echo -e "${LIGHT_BLUE}"
gitlab-ctl reconfigure
echo -e "${NC}"

echo -e "${LIGHT_GREEN}Setting root password...${NC}"
echo -e "${LIGHT_BLUE}"
gitlab-rails runner "user = User.where(id: 1).first; user.password = '${root_password}'; user.password_confirmation = '${root_password}'; user.save!"
echo -e "${NC}"

echo -e "${LIGHT_GREEN}Configuring Nginx for GitLab..."
if [ -f /etc/nginx/sites-available/gitlab ]; then
    echo -e "${LIGHT_GREEN}Nginx configuration for GitLab already exists.${NC}"
else
    cat > /etc/nginx/sites-available/gitlab <<EOF
server {
    listen 80;
    server_name ${gitlab_domain};

    location / {
        proxy_pass http://${gitlab_domain};
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

    ln -s /etc/nginx/sites-available/gitlab /etc/nginx/sites-enabled/gitlab
    nginx -t && systemctl reload nginx
    echo "Nginx configured successfully for GitLab."
fi

echo -e "${LIGHT_GREEN}GitLab Version:${NC}"
gitlab-rake gitlab:env:info | grep "GitLab version"

echo -e "${LIGHT_GREEN}Installation and configuration complete.${NC}"
echo -e "${LIGHT_GREEN}You can access GitLab at http://${gitlab_domain}${NC}"
echo -e "${LIGHT_GREEN}Login with the username 'root' and the password you set.${NC}"
