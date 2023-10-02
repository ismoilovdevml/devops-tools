#master
sudo apt update
sudo apt upgrade -y

sudo hostnamectl set-hostname "k8s-worker1"

127.0.0.1 localhost
127.0.0.1 k8s-master

# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
169.254.169.254 metadata.google.internal metadata

# k8s cluster nodes

10.128.0.3      k8s-master k8s-master
10.128.0.4      k8s-worker1 k8s-worker1
10.128.0.5      k8s-worker2 k8s-worker2

sudo swapoff -a
free -h

sudo nano /etc/fstab

swap ochirish kerak 
sudo mount -a
free -h

sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

sudo modprobe overlay

sudo modprobe br_netfilter



sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF


sudo sysctl --system
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates


docker o'rnatamiz

containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

sudo systemctl restart containerd

sudo systemctl enable containerd

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

sudo apt-add-repository "deb https://apt.kubernetes.io/ kubernetes-xenial main"

sudo apt update
sudo apt install -y kubelet kubeadm kubectl

sudo apt-mark hold kubelet kubeadm kubectl


sudo kubeadm init \
 --pod-network-cidr=10.10.0.0/16 \
 --control-plane-endpoint=k8s-master


  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config


kubectl cluster-info

kubeadm join k8s-master:6443 --token 297eah.yilc81gtmfl4ej7v \
        --discovery-token-ca-cert-hash sha256:8ea279a85d6d2ae094c906ab73ca1af94362805974381c3eb9130406b1c7f34f


curl https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml -O

sudo nano calico.yaml

4601 chi qator
10.10.0.0/16


kubectl apply -f calico.yaml

#---------------------------------------------------------------------------------------------------------------------------

#worker
sudo apt update
sudo apt upgrade -y

127.0.0.1 localhost
127.0.0.1 k8s-worker2

# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
169.254.169.254 metadata.google.internal metadata


# k8s cluster nodes

10.128.0.3      k8s-master k8s-master
10.128.0.4      k8s-worker1 k8s-worker1
10.128.0.5      k8s-worker2 k8s-worker2


sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
overlay
br_netfilter

sudo modprobe overlay

sudo modprobe br_netfilter

sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system

sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

docker o'rnatamiz

containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1



sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

sudo systemctl restart containerd

sudo systemctl enable containerd

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

sudo apt-add-repository "deb https://apt.kubernetes.io/ kubernetes-xenial main"

sudo apt update

sudo apt install -y kubelet kubeadm kubectl

sudo apt-mark hold kubelet kubeadm kubectl


sudo kubeadm join k8s-master:6443 --token 297eah.yilc81gtmfl4ej7v \
        --discovery-token-ca-cert-hash sha256:8ea279a85d6d2ae094c906ab73ca1af94362805974381c3eb9130406b1c7f34f