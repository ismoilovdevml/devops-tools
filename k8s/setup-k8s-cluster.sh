#!/bin/bash

# Install Docker
install_docker() {
  sudo apt-get update
  sudo apt-get install -y docker.io
}

# Install Kubernetes
install_kubernetes() {
  sudo apt-get update && sudo apt-get install -y apt-transport-https curl
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
  cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
  sudo apt-get update
  sudo apt-get install -y kubelet kubeadm kubectl
  sudo apt-mark hold kubelet kubeadm kubectl
}

# Initialize Kubernetes Master Node
initialize_master() {
  sudo kubeadm init --pod-network-cidr=192.168.0.0/16
}

# Set up local kubeconfig
setup_kubeconfig() {
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
}

# Install Calico
install_calico() {
  kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
}

# Main function
main() {
  if [[ $(hostname) == "master-node" ]]; then
    install_docker
    install_kubernetes
    initialize_master
    setup_kubeconfig
    install_calico
  elif [[ $(hostname) == "worker-node" ]]; then
    install_docker
    install_kubernetes
  else
    echo "Invalid hostname. Hostname should be either master-node or worker-node."
    exit 1
  fi
}

main
