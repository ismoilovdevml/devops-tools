#!/bin/bash
#
# Installs Flannel (CNI) and MetalLB (LoadBalancer) on a fresh cluster.
set -euo pipefail

kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

helm repo add metallb https://metallb.github.io/metallb
helm repo update
helm install metallb metallb/metallb --namespace metallb-system --create-namespace

# MetalLB in L2 mode needs kube-proxy's strictARP enabled. Show the diff, then
# actually apply it -- the previous version only ran `kubectl diff`, so the
# change was never made.
kubectl get configmap kube-proxy -n kube-system -o yaml \
    | sed -e "s/strictARP: false/strictARP: true/" \
    | kubectl diff -f - -n kube-system || true
kubectl get configmap kube-proxy -n kube-system -o yaml \
    | sed -e "s/strictARP: false/strictARP: true/" \
    | kubectl apply -f - -n kube-system

# Create the address pool for your network, then apply it. Adjust the range to
# a block of free addresses on the node network.
mkdir -p metallb
cd metallb || exit 1

cat > address-pool.yaml <<'EOF'
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default-pool
  namespace: metallb-system
spec:
  addresses:
    - 192.168.1.240-192.168.1.250   # <-- change to your free IP range
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: default-l2
  namespace: metallb-system
spec:
  ipAddressPools:
    - default-pool
EOF

echo "Edit metallb/address-pool.yaml for your network, then run:"
echo "  kubectl apply -f metallb/address-pool.yaml"
