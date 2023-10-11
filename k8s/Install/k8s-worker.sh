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

echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}"
cat << "EOF"
$$\   $$\  $$$$$$\   $$$$$$\        $$$$$$\                       $$\               $$\ $$\                     
$$ | $$  |$$  __$$\ $$  __$$\       \_$$  _|                      $$ |              $$ |$$ |                    
$$ |$$  / $$ /  $$ |$$ /  \__|        $$ |  $$$$$$$\   $$$$$$$\ $$$$$$\    $$$$$$\  $$ |$$ | $$$$$$\   $$$$$$\  
$$$$$  /   $$$$$$  |\$$$$$$\          $$ |  $$  __$$\ $$  _____|\_$$  _|   \____$$\ $$ |$$ |$$  __$$\ $$  __$$\ 
$$  $$<   $$  __$$<  \____$$\         $$ |  $$ |  $$ |\$$$$$$\    $$ |     $$$$$$$ |$$ |$$ |$$$$$$$$ |$$ |  \__|
$$ |\$$\  $$ /  $$ |$$\   $$ |        $$ |  $$ |  $$ | \____$$\   $$ |$$\ $$  __$$ |$$ |$$ |$$   ____|$$ |      
$$ | \$$\ \$$$$$$  |\$$$$$$  |      $$$$$$\ $$ |  $$ |$$$$$$$  |  \$$$$  |\$$$$$$$ |$$ |$$ |\$$$$$$$\ $$ |      
\__|  \__| \______/  \______/       \______|\__|  \__|\_______/    \____/  \_______|\__|\__| \_______|\__|      
                                                                                                             
   __                              _           
  / _| ___  _ __   _ __   ___   __| | ___  ___ 
 | |_ / _ \| '__| | '_ \ / _ \ / _` |/ _ \/ __|
 |  _| (_) | |    | | | | (_) | (_| |  __/\__ \
 |_|  \___/|_|    |_| |_|\___/ \__,_|\___||___/
                                            
EOF
echo -e "${NC}"
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"

# Get the current username
CURRENT_USERNAME=$(whoami)

# Update and upgrade system packages
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}Updating and upgrading system packages...${NC}"
echo -e "${LIGHT_BLUE}"
sudo apt update && sudo apt upgrade -y
echo -e "${NC}"

# Install required tools
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}Installing tools...${NC}"
echo -e "${LIGHT_BLUE}"
apt-get install net-tools jq git htop -y
echo -e "${NC}" 

# Load required modules for containerization
echo -e "${LIGHT_GREEN}Loading container modules...${NC}"
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
sudo modprobe overlay
sudo modprobe br_netfilter

# Disable swap (as recommended for K8s)
echo -e "${LIGHT_GREEN}Disabling swap...${NC}"
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a

# Ensure modules are loaded on boot
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF


# Set sysctl settings for Kubernetes
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

echo -e "${LIGHT_BLUE}"
sudo sysctl --system
echo -e "${NC}"

# Install additional utilities
echo -e "${LIGHT_GREEN}Installing additional utilities...${NC}"
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_BLUE}"
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
echo -e "${NC}"


# Docker installation
echo -e "${LIGHT_GREEN}Installing Docker...${NC}"
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_BLUE}"
sudo apt-get update -y
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
echo -e "${NC}"

# Adjust Docker socket permissions
echo -e "${LIGHT_GREEN}Adjusting Docker permissions...${NC}"
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
sudo chmod 666 /var/run/docker.sock
sudo chown $CURRENT_USERNAME:docker /var/run/docker.sock

# Configure Docker with overlay2 storage driver and systemd cgroup driver
echo -e "${LIGHT_GREEN}Configuring Docker...${NC}"
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_BLUE}"
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
echo -e "${NC}"

# Restart and enable Docker service
echo -e "${LIGHT_BLUE}"
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker
echo -e "${NC}"

# Configure and restart containerd
echo -e "${LIGHT_GREEN}Configuring containerd...${NC}"
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_BLUE}"
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd
echo -e "${NC}"

# Kubernetes installation
echo -e "${LIGHT_GREEN}Installing Kubernetes (K8s)...${NC}"
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_BLUE}"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-add-repository "deb https://apt.kubernetes.io/ kubernetes-xenial main"
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo systemctl enable kubelet
sudo apt-mark hold kubelet kubeadm kubectl
echo -e "${NC}"

echo -e "${LIGHT_GREEN}Kubernetes has been successfully installed${NC}"


echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}"
cat << "EOF"
$$\ $$\                                                                             $$\ $$\             
\$$\\$$\                                                                            \$$\\$$\            
 \$$\\$$\      $$$$$$$\ $$\   $$\  $$$$$$$\  $$$$$$$\  $$$$$$\   $$$$$$$\  $$$$$$$\  \$$\\$$\           
  \$$\\$$\    $$  _____|$$ |  $$ |$$  _____|$$  _____|$$  __$$\ $$  _____|$$  _____|  \$$\\$$\          
  $$  |\$$\   \$$$$$$\  $$ |  $$ |$$ /      $$ /      $$$$$$$$ |\$$$$$$\  \$$$$$$\    $$  |\$$\         
 $$  /  \$$\   \____$$\ $$ |  $$ |$$ |      $$ |      $$   ____| \____$$\  \____$$\  $$  /  \$$\        
$$  /    \$$\ $$$$$$$  |\$$$$$$  |\$$$$$$$\ \$$$$$$$\ \$$$$$$$\ $$$$$$$  |$$$$$$$  |$$  /    \$$\       
\__/      \__|\_______/  \______/  \_______| \_______| \_______|\_______/ \_______/ \__/      \__|      
                                                                                                        
EOF
echo -e "${NC}"

echo -e "${YELLOW}-------------------------------------------------------------------------------------------------------------------------${NC}"

echo -e "${YELLOW}----------------------Next steps-------------------------${NC}"
echo -e "${YELLOW}[*]Join the master via kubeadm join${NC}"
echo -e "${LIGHT_GREEN}----------------------------------------------------${NC}"
