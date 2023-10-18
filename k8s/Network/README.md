### Install Flannel

[Flannel Github Repo](https://github.com/flannel-io/flannel)

```bash
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

### Configure Metallb

```bash
# see what changes would be made, returns nonzero returncode if different
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl diff -f - -n kube-system

# actually apply the changes, returns nonzero returncode on errors only
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system
```

```bash
helm repo add metallb https://metallb.github.io/metallb
helm repo update
helm install metallb metallb/metallb --namespace metallb-system --create-namespace
```

### Metallb Address Pool

```bash
mkdir metallb
cd metallb
nano address-pool.yaml
```
```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 10.128.0.200-10.128.0.220
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  ipAddressPools:
  - first-pool
```