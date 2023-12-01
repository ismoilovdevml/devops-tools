#!/bin/bash

# Get the current username
CURRENT_USERNAME=$(whoami)

# Update and upgrade system packages
sudo apt update && sudo apt upgrade -y
# Install additional utilities
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https 

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose

# Adjust Docker socket permissions
sudo chmod 666 /var/run/docker.sock
sudo chown $CURRENT_USERNAME:docker /var/run/docker.sock

# Restart and enable Docker service
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker