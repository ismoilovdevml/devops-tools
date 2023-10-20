## Install and Configure `kubeview`


**Install kubeview with helm**
```bash
helm repo add cowboysysop https://cowboysysop.github.io/charts/
helm repo update
helm install kubeview cowboysysop/kubeview --namespace kubeview --create-namespace
kubectl get svc -n kubeview
```

Create `kubeview-ingress.yaml` 

```bash
nano kubeview-ingress.yaml
```
`kubeview-ingress.yaml`

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kubeview-ingress
  namespace: kubeview
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  ingressClassName: "nginx"
  rules:
  - host: kube.test.uz
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: kubeview
            port:
              number: 8000
  tls:
  - hosts:
    - kube.test.uz
    secretName: kubeview-tls
```

Apply `kubeview-ingress.yaml`

```bash
kubectl apply -f kubeview-ingress.yaml
```