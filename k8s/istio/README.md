### Install and Configure Istio Service Mesh

```bash
kubectl create namespace istio-system
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
helm search repo istio/base
helm show values istio/base --version 1.19.3 > istio-base-default.yaml
helm install istio-base istio/base -n istio-system --set defaultRevision=default
helm ls -n istio-system
helm install istiod istio/istiod -n istio-system --wait
helm status istiod -n istio-system
kubectl get deployments -n istio-system --output wide
```


### Istio Gateway

```bash
kubectl create namespace istio-ingress
helm install istio-ingressgateway istio/gateway -n istio-ingress
```


### Uninstall Istio


```bash
helm ls -n istio-system
helm delete istio-ingress -n istio-ingress
kubectl delete namespace istio-ingress
helm delete istiod -n istio-system
helm delete istio-base -n istio-system
kubectl delete namespace istio-system
kubectl get crd -oname | grep --color=never 'istio.io' | xargs kubectl delete
kubectl delete validatingwebhookconfiguration istiod-default-validator
```


### Kiali UI

```bash
helm install \
  --namespace istio-system \
  --set auth.strategy="anonymous" \
  --repo https://kiali.org/helm-charts \
  kiali-server \
  kiali-server
```

### Uninstall Kiali

```bash
kubectl delete kiali --all --all-namespaces
helm uninstall --namespace kiali-operator kiali-operator
kubectl delete crd kialis.kiali.io
kubectl patch kiali kiali -n istio-system -p '{"metadata":{"finalizers": []}}' --type=merge
helm uninstall --namespace istio-system kiali-server
```
### Prometheus


```bash
helm install prometheus istio/prometheus -n istio-system
kubectl edit configmap kiali -n istio-system
kubectl delete pod -l app=kiali -n istio-system
kubectl get pods -n istio-system | grep prometheus

```

### Expose Kiali UI with NGINX Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kiali-ingress
  namespace: istio-system
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  ingressClassName: "nginx"
  rules:
  - host: kiali.xilol.uz
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: kiali
            port:
              number: 20001
  tls:
  - hosts:
    - kiali.xilol.uz
    secretName: kiali-tls
```