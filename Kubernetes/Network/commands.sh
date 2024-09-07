kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
helm repo add metallb https://metallb.github.io/metallb
helm repo update
helm install metallb metallb/metallb --namespace metallb-system --create-namespace
kubectl get configmap kube-proxy -n kube-system -o yaml | sed -e "s/strictARP: false/strictARP: true/" | kubectl diff -f - -n kube-system
mkdir metallb
cd metallb
nano address-pool.yaml
