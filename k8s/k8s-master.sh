#!/bin/bash

# Master
sudo apt update
sudo apt upgrade -y

sudo hostnamectl set-hostname "k8s-master"

echo "127.0.0.1 localhost
127.0.0.1 k8s-master
10.128.0.3 k8s-master k8s-master
10.128.0.4 k8s-worker1 k8s-worker1
10.128.0.5 k8s-worker2 k8s-worker2" | sudo tee -a /etc/hosts

sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo mount -a

echo -e "overlay\nbr_netfilter" | sudo tee /etc/modules-load.d/containerd.conf
sudo modprobe overlay
sudo modprobe br_netfilter

echo -e "net.bridge.bridge-nf-call-ip6tables = 1\nnet.bridge.bridge-nf-call-iptables = 1\nnet.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/kubernetes.conf
sudo sysctl --system
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates containerd

sudo systemctl restart containerd
sudo systemctl enable containerd

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-add-repository "deb https://apt.kubernetes.io/ kubernetes-xenial main"
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo kubeadm init --pod-network-cidr=10.10.0.0/16 --control-plane-endpoint=k8s-master

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl cluster-info

curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml
sed -i 's?192.168.0.0/16?10.10.0.0/16?g' calico.yaml
kubectl apply -f calico.yaml
