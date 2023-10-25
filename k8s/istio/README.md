### Install and Configure Istio Service Mesh

```bash
kubectl create namespace istio-system
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
helm install istio-base istio/base -n istio-system
helm install istiod istio/istiod -n istio-system
helm install istio-ingress istio/gateway -n istio-system
helm install istio-egress istio/gateway -n istio-system
kubectl get deployments -n istio-system --output wide
```


### Check Status

```bash
kubectl get services -n istio-system
kubectl get pods -n istio-system
```

### Kiali UI

```bash
helm repo add kiali https://kiali.org/helm-charts
helm repo update kiali
helm install \
  --namespace istio-system \
  --set auth.strategy="anonymous" \
  --repo https://kiali.org/helm-charts \
  kiali-server \
  kiali-server
```

### Prometheus/Istio Ingress Gateway/ Jaeger

```bash
kubectl apply  -f https://raw.githubusercontent.com/istio/istio/release-1.19/samples/addons/prometheus.yaml --namespace istio-system
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.19/samples/addons/jaeger.yaml --namespace istio-system
helm install istio-ingressgateway istio/gateway -n
kubectl get pods -n istio-system
```

### Inject namespace


```bash
kubectl label namespace jenkins istio-injection=enabled --overwrite
kubectl get namespace -L istio-injection
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
  - host: kiali.test.uz
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
    - kiali.test.uz
    secretName: kiali-tls
```

### Get Token

```bash
kubectl get secret -n istio-system $(kubectl get sa kiali-service-account -n istio-system -o "jsonpath={.secrets[0].name}") -o jsonpath={.data.token} | base64 -d
kubectl -n istio-system create token kiali-service-account
```


### Uninstall Kiali

```bash
kubectl delete kiali --all --all-namespaces
helm uninstall --namespace kiali-operator kiali-operator
kubectl delete crd kialis.kiali.io
kubectl patch kiali kiali -n istio-system -p '{"metadata":{"finalizers": []}}' --type=merge
helm uninstall --namespace istio-system kiali-server
```

### Uninstall Istio

```bash
helm ls -n istio-system
helm delete istio-ingress -n istio-ingress
kubectl delete namespace istio-ingress
helm uninstall istio-egress -n istio-system
helm uninstall istio-ingress -n istio-system
helm uninstall istiod -n istio-system
helm uninstall istio-base -n istio-system
kubectl delete namespace istio-system
kubectl get crd -oname | grep --color=never 'istio.io' | xargs kubectl delete
kubectl delete validatingwebhookconfiguration istiod-default-validator
```