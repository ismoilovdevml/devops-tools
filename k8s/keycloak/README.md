## Install and Configure Kyecloak

### Install Keycloak

```bash
helm repo add codecentric https://codecentric.github.io/helm-charts
helm repo update
helm install keycloak codecentric/keycloak --version 15.0.2 --namespace keycloak --create-namespace
```

### Set admin login password

```bash
helm show values codecentric/keycloak >  codecentric.yaml
nano codecentric.yaml
```

`codecentric.yaml` 107 - line

```bash
extraEnv: |
    - name: KEYCLOAK_USER
      value: admin
    - name: KEYCLOAK_PASSWORD
      value: fakenafona_admin
    - name: JAVA_TOOL_OPTIONS
      value: "-Dkeycloak.profile.feature.upload_scripts=enabled"
  # - name: KEYCLOAK_LOGLEVEL
  #   value: DEBUG
  # - name: WILDFLY_LOGLEVEL
  #   value: DEBUG
  # - name: CACHE_OWNERS_COUNT
  #   value: "2"
  # - name: CACHE_OWNERS_AUTH_SESSIONS_COUNT
  #   value: "2"
```

Apply this configration

```bash
helm upgrade keycloak codecentric/keycloak -f codecentric.yaml --namespace keycloak
```

### Add Frontent URL

```bash
export KUBE_EDITOR=nano
kubectl edit sts keycloak -n keycloak
```

```yaml
          valueFrom:
            secretKeyRef:
              key: postgresql-password
              name: keycloak-postgresql
        - name: KEYCLOAK_USER
          value: admin
        - name: KEYCLOAK_PASSWORD
          value: fakenafona_admin
        - name: KEYCLOAK_FRONTEND_URL
          value: https://keycloak.test.uz/auth/
```

### Expose keycloak with NGINX Ingress

```bash
nano keycloak-ingress.yaml
```
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: keycloak-ingress
  namespace: keycloak
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  ingressClassName: "nginx"
  rules:
  - host: keycloak.test.uz
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: keycloak-headless
            port:
              number: 80
  tls:
  - hosts:
    - keycloak.test.uz
    secretName: keycloak-tls
```

Applty this configration and visit keycloak

```bash
kubectl apply -f keycloak-ingress.yaml
```