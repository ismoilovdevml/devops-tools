## Install and Configure Kubernetes Dashboard

### Install Kubernetes Dashboard

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml --namespace=kubernetes-dashboard
mkdir dashboard
cd dashboard/
nano service-account.yaml
```

**service-account.yaml**

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
```

```bash
nano clusterrolebinding.yaml
```
`clusterrolebinding.yaml`

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
```

### Expose K8s dashboard with NGINX Ingress 

```bash
nano dashboard-ingress.yaml
```

`dashboard-ingress.yaml`

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: k8s-dashboard-ingress
  namespace: kubernetes-dashboard
  annotations:
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    nginx.org/ssl-services: "kubernetes-dashboard"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  ingressClassName: "nginx"
  rules:
  - host: dashboard.test.uz
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: kubernetes-dashboard
            port:
              number: 443
  tls:
  - hosts:
    - dashboard.test.uz
    secretName: k8s-dashboard-tls
```

#### Apply this configrations

```bash
kubectl apply -f dashboard-ingress.yaml
kubectl apply -f service-account.yaml
kubectl apply -f clusterrolebinding.yaml
```

### Get Token

```bash
kubectl -n kubernetes-dashboard create token admin-user
```