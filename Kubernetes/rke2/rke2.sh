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

$$$$$$$\  $$\   $$\ $$$$$$$$\  $$$$$$\        $$$$$$\                       $$\               $$\ $$\                     
$$  __$$\ $$ | $$  |$$  _____|$$  __$$\       \_$$  _|                      $$ |              $$ |$$ |                    
$$ |  $$ |$$ |$$  / $$ |      \__/  $$ |        $$ |  $$$$$$$\   $$$$$$$\ $$$$$$\    $$$$$$\  $$ |$$ | $$$$$$\   $$$$$$\  
$$$$$$$  |$$$$$  /  $$$$$\     $$$$$$  |        $$ |  $$  __$$\ $$  _____|\_$$  _|   \____$$\ $$ |$$ |$$  __$$\ $$  __$$\ 
$$  __$$< $$  $$<   $$  __|   $$  ____/         $$ |  $$ |  $$ |\$$$$$$\    $$ |     $$$$$$$ |$$ |$$ |$$$$$$$$ |$$ |  \__|
$$ |  $$ |$$ |\$$\  $$ |      $$ |              $$ |  $$ |  $$ | \____$$\   $$ |$$\ $$  __$$ |$$ |$$ |$$   ____|$$ |      
$$ |  $$ |$$ | \$$\ $$$$$$$$\ $$$$$$$$\       $$$$$$\ $$ |  $$ |$$$$$$$  |  \$$$$  |\$$$$$$$ |$$ |$$ |\$$$$$$$\ $$ |      
\__|  \__|\__|  \__|\________|\________|      \______|\__|  \__|\_______/    \____/  \_______|\__|\__| \_______|\__|      
                                                                                                                             
EOF
echo -e "${NC}"
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"


#############################################
# YOU SHOULD ONLY NEED TO EDIT THIS SECTION #
#############################################

# Version of Kube-VIP to deploy
KVVERSION="v0.8.2"

# Set the IP addresses of the admin, masters, and workers nodes
admin=192.168.3.5
master1=10.128.0.22
master2=10.128.0.23
master3=10.162.0.2
worker1=10.128.0.24
worker2=10.188.0.2
worker3=10.188.0.3

# User of remote machines
user=ubuntu

# Interface used on remotes
interface=ens4

# Set the virtual IP address (VIP)
vip=10.128.0.25

# Array of all master nodes
allmasters=($master1 $master2 $master3)

# Array of master nodes
masters=($master2 $master3)

# Array of worker nodes
workers=($worker1 $worker2 $worker3)

# Array of all
all=($master1 $master2 $master3 $worker1 $worker2 $worker3)

# Array of all minus master1
allnomaster1=($master2 $master3 $worker1 $worker2 $worker3)

#Loadbalancer IP range
lbrange=10.128.0.200-10.128.0.240

#ssh certificate name variable
certName=id_rsa

#############################################
#            DO NOT EDIT BELOW              #
#############################################
# For testing purposes - in case time is wrong due to VM snapshots
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}Configuring Time Synchronization...${NC}"
echo -e "${LIGHT_BLUE}"
sudo timedatectl set-ntp off
sudo timedatectl set-ntp on
echo -e "${NC}"


# Move SSH certs to ~/.ssh and change permissions
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}Copying SSH Certificates and Setting Permissions...${NC}"
echo -e "${LIGHT_BLUE}"
cp /home/$user/{$certName,$certName.pub} /home/$user/.ssh
chmod 600 /home/$user/.ssh/$certName 
chmod 644 /home/$user/.ssh/$certName.pub
echo -e "${NC}"

# Install Kubectl if not already present
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}Checking if Kubectl is installed...${NC}"
echo -e "${LIGHT_BLUE}"
if ! command -v kubectl version &> /dev/null
then
    echo -e " \033[31;5mKubectl not found, installing\033[0m"
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
else
    echo -e " \033[32;5mKubectl already installed\033[0m"
fi
echo -e "${NC}"

# Create SSH Config file to ignore checking (don't use in production!)
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}Disabling StrictHostKeyChecking in SSH config...${NC}"
echo -e "${LIGHT_BLUE}"
sed -i '1s/^/StrictHostKeyChecking no\n/' ~/.ssh/config
echo -e "${NC}"

#add ssh keys for all nodes
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}Copying SSH keys to all nodes...${NC}"
echo -e "${LIGHT_BLUE}"
for node in "${all[@]}"; do
  ssh-copy-id $user@$node
done
echo -e "${NC}"

# Step 1: Create Kube VIP
# create RKE2's self-installing manifest dir
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}Creating RKE2 manifests directory...${NC}"
echo -e "${LIGHT_BLUE}"
sudo mkdir -p /var/lib/rancher/rke2/server/manifests
echo -e "${NC}"

# Install the kube-vip deployment into rke2's self-installing manifest folder
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}Downloading and configuring kube-vip manifest...${NC}"
echo -e "${LIGHT_BLUE}"
curl -sO https://raw.githubusercontent.com/ismoilovdevml/devops-tools/main/Kubernetes/rke2/kube-vip
cat kube-vip | sed 's/$interface/'$interface'/g; s/$vip/'$vip'/g' > $HOME/kube-vip.yaml
sudo mv kube-vip.yaml /var/lib/rancher/rke2/server/manifests/kube-vip.yaml
echo -e "${NC}"

# Find/Replace all k3s entries to represent rke2
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}Modifying kube-vip manifest to use RKE2...${NC}"
echo -e "${LIGHT_BLUE}"
sudo sed -i 's/k3s/rke2/g' /var/lib/rancher/rke2/server/manifests/kube-vip.yaml
echo -e "${NC}"
# copy kube-vip.yaml to home directory
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}Copying kube-vip manifest to the home directory...${NC}"
echo -e "${LIGHT_BLUE}"
sudo cp /var/lib/rancher/rke2/server/manifests/kube-vip.yaml ~/kube-vip.yaml
echo -e "${NC}"
# change owner
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}Changing ownership of kube-vip.yaml...${NC}"
echo -e "${LIGHT_BLUE}"
sudo chown $user:$user kube-vip.yaml
echo -e "${NC}"
# make kube folder to run kubectl later
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}Creating .kube directory for kubectl...${NC}"
echo -e "${LIGHT_BLUE}"
mkdir ~/.kube
echo -e "${NC}"

# create the rke2 config file
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}Creating RKE2 config directory and config.yaml file...${NC}"
echo -e "${LIGHT_BLUE}"
sudo mkdir -p /etc/rancher/rke2
touch config.yaml
echo "tls-san:" >> config.yaml 
echo "  - $vip" >> config.yaml
echo "  - $master1" >> config.yaml
echo "  - $master2" >> config.yaml
echo "  - $master3" >> config.yaml
echo "write-kubeconfig-mode: 0644" >> config.yaml
echo "disable:" >> config.yaml
echo "  - rke2-ingress-nginx" >> config.yaml
echo -e "${NC}"
# copy config.yaml to rancher directory
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}Copying config.yaml to /etc/rancher/rke2 directory...${NC}"
echo -e "${LIGHT_BLUE}"
sudo cp ~/config.yaml /etc/rancher/rke2/config.yaml
echo -e "${NC}"

# update path with rke2-binaries
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}Configuring environment variables and kubectl alias...${NC}"
echo -e "${LIGHT_BLUE}"
echo 'export KUBECONFIG=/etc/rancher/rke2/rke2.yaml' >> ~/.bashrc ; echo 'export PATH=${PATH}:/var/lib/rancher/rke2/bin' >> ~/.bashrc ; echo 'alias k=kubectl' >> ~/.bashrc ; source ~/.bashrc ;
echo -e "${NC}"

# Step 2: Copy kube-vip.yaml and certs to all masters
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}Copying kube-vip.yaml, config.yaml, and SSH keys to all master nodes...${NC}"
echo -e "${LIGHT_BLUE}"
for newnode in "${allmasters[@]}"; do
  scp -i ~/.ssh/$certName $HOME/kube-vip.yaml $user@$newnode:~/kube-vip.yaml
  scp -i ~/.ssh/$certName $HOME/config.yaml $user@$newnode:~/config.yaml
  scp -i ~/.ssh/$certName ~/.ssh/{$certName,$certName.pub} $user@$newnode:~/.ssh
  echo -e " \033[32;5mCopied successfully!\033[0m"
done
echo -e "${NC}"

# Step 3: Connect to Master1 and move kube-vip.yaml and config.yaml. Then install RKE2, copy token back to admin machine. We then use the token to bootstrap additional masternodes

echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}Connecting to Master1, installing RKE2, and copying token...${NC}"
echo -e "${LIGHT_BLUE}"
ssh -tt $user@$master1 -i ~/.ssh/$certName sudo su <<EOF
mkdir -p /var/lib/rancher/rke2/server/manifests
mv kube-vip.yaml /var/lib/rancher/rke2/server/manifests/kube-vip.yaml
mkdir -p /etc/rancher/rke2
mv config.yaml /etc/rancher/rke2/config.yaml
echo 'export KUBECONFIG=/etc/rancher/rke2/rke2.yaml' >> ~/.bashrc ; echo 'export PATH=${PATH}:/var/lib/rancher/rke2/bin' >> ~/.bashrc ; echo 'alias k=kubectl' >> ~/.bashrc ; source ~/.bashrc ;
curl -sfL https://get.rke2.io | sh -
systemctl enable rke2-server.service
systemctl start rke2-server.service
echo "StrictHostKeyChecking no" > ~/.ssh/config
ssh-copy-id -i /home/$user/.ssh/$certName $user@$admin
scp -i /home/$user/.ssh/$certName /var/lib/rancher/rke2/server/token $user@$admin:~/token
scp -i /home/$user/.ssh/$certName /etc/rancher/rke2/rke2.yaml $user@$admin:~/.kube/rke2.yaml
exit
EOF
echo -e " \033[32;5mMaster1 Completed\033[0m"
echo -e "${NC}"

# Step 4: Set variable to the token we just extracted, set kube config location
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}Configuring kubeconfig and updating Master1 IP...${NC}"
echo -e "${LIGHT_BLUE}"
token=`cat token`
sudo cat ~/.kube/rke2.yaml | sed 's/127.0.0.1/'$master1'/g' > $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=${HOME}/.kube/config
sudo cp ~/.kube/config /etc/rancher/rke2/rke2.yaml
kubectl get nodes -o wide
echo -e "${NC}"

# Step 5: Install kube-vip as network LoadBalancer - Install the kube-vip Cloud Provider
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}Applying Kube-Vip RBAC and cloud controller manifests...${NC}"
echo -e "${LIGHT_BLUE}"
kubectl apply -f https://kube-vip.io/manifests/rbac.yaml
kubectl apply -f https://raw.githubusercontent.com/kube-vip/kube-vip-cloud-provider/main/manifest/kube-vip-cloud-controller.yaml
echo -e "${NC}"

# Step 6: Add other Masternodes, note we import the token we extracted from step 3
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}Adding additional master nodes to the RKE2 cluster...${NC}"
echo -e "${LIGHT_BLUE}"
for newnode in "${masters[@]}"; do
  ssh -tt $user@$newnode -i ~/.ssh/$certName sudo su <<EOF
  mkdir -p /etc/rancher/rke2
  touch /etc/rancher/rke2/config.yaml
  echo "token: $token" >> /etc/rancher/rke2/config.yaml
  echo "server: https://$master1:9345" >> /etc/rancher/rke2/config.yaml
  echo "tls-san:" >> /etc/rancher/rke2/config.yaml
  echo "  - $vip" >> /etc/rancher/rke2/config.yaml
  echo "  - $master1" >> /etc/rancher/rke2/config.yaml
  echo "  - $master2" >> /etc/rancher/rke2/config.yaml
  echo "  - $master3" >> /etc/rancher/rke2/config.yaml
  curl -sfL https://get.rke2.io | sh -
  systemctl enable rke2-server.service
  systemctl start rke2-server.service
  exit
EOF
  echo -e " \033[32;5mMaster node joined successfully!\033[0m"
done
echo -e "${NC}"

echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}Checking the status of all nodes in the RKE2 cluster...${NC}"
echo -e "${LIGHT_BLUE}"
kubectl get nodes -o wide
echo -e "${NC}"

# Step 7: Add Workers
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}Adding worker nodes to the RKE2 cluster...${NC}"
echo -e "${LIGHT_BLUE}"
for newnode in "${workers[@]}"; do
  ssh -tt $user@$newnode -i ~/.ssh/$certName sudo su <<EOF
  mkdir -p /etc/rancher/rke2
  touch /etc/rancher/rke2/config.yaml
  echo "token: $token" >> /etc/rancher/rke2/config.yaml
  echo "server: https://$vip:9345" >> /etc/rancher/rke2/config.yaml
  echo "node-label:" >> /etc/rancher/rke2/config.yaml
  echo "  - worker=true" >> /etc/rancher/rke2/config.yaml
  echo "  - longhorn=true" >> /etc/rancher/rke2/config.yaml
  curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -
  systemctl enable rke2-agent.service
  systemctl start rke2-agent.service
  exit
EOF
  echo -e " \033[32;5mWorker node joined successfully!\033[0m"
done
echo -e "${NC}"



echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}Checking the status of all nodes in the RKE2 cluster...${NC}"
echo -e "${LIGHT_BLUE}"
kubectl get nodes -o wide
echo -e "${NC}"

# Step 8: Install Metallb
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}Deploying MetalLB to the RKE2 cluster...${NC}"
echo -e "${LIGHT_BLUE}"
echo -e " \033[32;5mDeploying Metallb\033[0m"
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml
echo -e "${NC}"

# Download ipAddressPool and configure using lbrange above
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}Downloading and configuring the MetalLB IP Address Pool...${NC}"
echo -e "${LIGHT_BLUE}"
curl -sO https://raw.githubusercontent.com/ismoilovdevml/devops-tools/main/Kubernetes/rke2/ipAddressPool
cat ipAddressPool | sed 's/$lbrange/'$lbrange'/g' > $HOME/ipAddressPool.yaml
echo -e "${NC}"

# Step 9: Deploy IP Pools and l2Advertisement
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}Waiting for MetalLB controller to be ready and configuring IP Address Pool and Layer 2 Advertisement...${NC}"
echo -e "${LIGHT_BLUE}"
echo -e " \033[32;5mAdding IP Pools, waiting for Metallb to be available first. This can take a long time as we're likely being rate limited for container pulls...\033[0m"
kubectl wait --namespace metallb-system \
                --for=condition=ready pod \
                --selector=component=controller \
                --timeout=1800s
kubectl apply -f ipAddressPool.yaml
kubectl apply -f https://raw.githubusercontent.com/ismoilovdevml/devops-tools/main/Kubernetes/rke2/l2Advertisement.yaml
echo -e "${NC}"

# Step 10: Install Rancher (Optional - Delete if not required)
#Install Helm
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}Downloading and installing Helm...${NC}"
echo -e "${LIGHT_BLUE}"
echo -e " \033[32;5mInstalling Helm\033[0m"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
echo -e "${NC}"

# Add Rancher Helm Repo & create namespace
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}Adding Rancher Helm repository and creating cattle-system namespace...${NC}"
echo -e "${LIGHT_BLUE}"
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
kubectl create namespace cattle-system
echo -e "${NC}"

# Install Cert-Manager
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}Installing cert-manager and applying CRDs...${NC}"
echo -e "${LIGHT_BLUE}"
echo -e " \033[32;5mDeploying Cert-Manager\033[0m"
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
--namespace cert-manager \
--create-namespace \
--version v1.13.2
kubectl get pods --namespace cert-manager
echo -e "${NC}"

# Install Rancher
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}Deploying Rancher to the RKE2 cluster...${NC}"
echo -e "${LIGHT_BLUE}"
echo -e " \033[32;5mDeploying Rancher\033[0m"
helm install rancher rancher-latest/rancher \
 --namespace cattle-system \
 --set hostname=rancher.my.org \
 --set bootstrapPassword=admin
kubectl -n cattle-system rollout status deploy/rancher
kubectl -n cattle-system get deploy rancher
echo -e "${NC}"

# Add Rancher LoadBalancer
echo -e "${YELLOW}---------------------------------------------------------------------------------------------------------------------${NC}"
echo -e "${LIGHT_GREEN}Exposing Rancher as a LoadBalancer service...${NC}"
echo -e "${LIGHT_BLUE}"
kubectl get svc -n cattle-system
kubectl expose deployment rancher --name=rancher-lb --port=443 --type=LoadBalancer -n cattle-system
while [[ $(kubectl get svc -n cattle-system 'jsonpath={..status.conditions[?(@.type=="Pending")].status}') = "True" ]]; do
   sleep 5
   echo -e " \033[32;5mWaiting for LoadBalancer to come online\033[0m" 
done
kubectl get svc -n cattle-system

echo -e " \033[32;5mAccess Rancher from the IP above - Password is admin!\033[0m"
echo -e "${NC}"