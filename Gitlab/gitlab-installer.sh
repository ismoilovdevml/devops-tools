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

echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}"
cat << "EOF"
                                        .         
        *((((                         ((((        
       *(((((.                       ((((((       
      .(((((((                      .(((((((      
     .(((((((((                     (((((((((     
     (((((((((((                   (((((((((((    
    (((((((((((((((((((((((((((((((((((((((((((   
   (((((((((((((((((((((((((((((((((((((((((((((  
  //////(((((((((((((((((((((((((((((((((((////// 
  //////////(((((((((((((((((((((((((((////////// 
  /////////////(((((((((((((((((((((///////////// 
   ///////////////((((((((((((((////////////////  
    //////////////////(((((((/////////////////*   
       //////////////////(//////////////////      
          ////////////******////////////*         
             ./////************//////             
                 *****************                
                    **********,                   
                       ****   

EOF
echo -e "${NC}"
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
                   
read -p "Enter the domain for your GitLab instance: " gitlab_domain

read -s -p "Enter the desired password for the GitLab root user: " root_password
echo


echo "Updating system packages..."
apt-get update -y
apt-get upgrade -y

echo "Installing necessary dependencies..."
apt-get install -y curl openssh-server ca-certificates tzdata perl

echo "Installing Postfix..."
DEBIAN_FRONTEND=noninteractive apt-get install -y postfix

echo "Adding GitLab package repository..."
curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | bash

echo "Installing GitLab..."
EXTERNAL_URL="http://${gitlab_domain}" apt-get install -y gitlab-ee

echo "Configuring GitLab..."
gitlab-ctl reconfigure

echo "Setting root password..."
gitlab-rails runner "user = User.where(id: 1).first; user.password = '${root_password}'; user.password_confirmation = '${root_password}'; user.save!"

echo "Configuring Nginx for GitLab..."
if [ -f /etc/nginx/sites-available/gitlab ]; then
    echo "Nginx configuration for GitLab already exists."
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

echo "GitLab Version:"
gitlab-rake gitlab:env:info | grep "GitLab version"

echo "Installation and configuration complete."
echo "You can access GitLab at http://${gitlab_domain}"
echo "Login with the username 'root' and the password you set."
