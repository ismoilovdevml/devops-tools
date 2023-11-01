## Install and Configure Vault

### Install vault with Helm

```bash
helm repo add hashicorp https://helm.releases.hashicorp.com
helm search repo hashicorp/vault
helm install vault hashicorp/vault --namespace vault --create-namespace
```