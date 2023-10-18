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

```bash
kubectl apply -f address-pool.yml 
```

### NINX Ingress

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace
kubectl get svc -n ingress-nginx
```

### Install and Configure HAProxy

```bash
sudo apt update && sudoa apt upgrade
sudo apt install haproxy
sudo nano /etc/haproxy/haproxy.cfg 
```

```yaml
defaults
    log	global
    mode	tcp
#   option	httplog
    option	dontlognull
    timeout connect 5000
    timeout client  50000
    timeout server  50000
    errorfile 400 /etc/haproxy/errors/400.http
    errorfile 403 /etc/haproxy/errors/403.http
    errorfile 408 /etc/haproxy/errors/408.http
    errorfile 500 /etc/haproxy/errors/500.http
    errorfile 502 /etc/haproxy/errors/502.http
    errorfile 503 /etc/haproxy/errors/503.http
    errorfile 504 /etc/haproxy/errors/504.http

frontend ingress
   mode tcp
   bind :80
   default_backend ingress_servers

backend ingress_servers
   mode tcp
   server s1 10.128.0.200:80 check

frontend ingress_tls
   mode tcp
   bind :443
   default_backend ingress_servers_tls

backend ingress_servers_tls
   mode tcp
   server s2 10.128.0.200:443 check
```

#### Apply this configration

```bash
haproxy -c -f haproxy.cfg
sudo systemctl enable haproxy
sudo systemctl start haproxy
sudo systemctl restart haproxy
sudo systemctl status haproxy
```

### Install And Configure Cert-Manager
https://cert-manager.io/docs/installation/helm/

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.1/cert-manager.crds.yaml

helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.13.1 \
```

### Install and Configure Longhorn

[Longhorn](https://longhorn.io/)

```bash
helm repo add longhorn https://charts.longhorn.io
helm repo update
helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace
kubectl get svc -n loghorn-system
```

#### Expose Longhorn
```bash
mkdir ingress
cd ingress
nano longhorn-ingress.yaml
```

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: longhorn-ingress
  namespace: longhorn-system
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  ingressClassName: "nginx"
  rules:
  - host: longhorn.test.uz
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: longhorn-frontend
            port:
              number: 80
  tls:
  - hosts:
    - longhorn.test.uz
    secretName: longhorn-tls
```