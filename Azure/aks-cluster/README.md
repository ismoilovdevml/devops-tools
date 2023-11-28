## Create an Azure Kubernetes Service (AKS) cluster using Terraform

### Authenticate to Azure via a Microsoft account

```bash
az login
az account show
az account list --query "[?user.name=='<microsoft_account_email>'].{Name:name, ID:id, Default:isDefault}" --output Table
az account set --subscription "<subscription_id_or_subscription_name>"
```

### Create a service principal(Bash)

```bash
export MSYS_NO_PATHCONV=1
az ad sp create-for-rbac --name <service_principal_name> --role Contributor --scopes /subscriptions/<subscription_id>
```

### Specify service principal credentials in environment variables(Bash)

```bash
export ARM_SUBSCRIPTION_ID="<azure_subscription_id>"
export ARM_TENANT_ID="<azure_subscription_tenant_id>"
export ARM_CLIENT_ID="<service_principal_appid>"
export ARM_CLIENT_SECRET="<service_principal_password>"
```

```bash
. ~/.bashrc
```

```bash
printenv | grep ^ARM*
```

### Initialize Terraform

```bash
terraform init -upgrade
```

### Create a Terraform execution plan

```bash
terraform plan -out main.tfplan
```
### Apply a Terraform execution plan

```bash
terraform apply main.tfplan
```

### Verify the results

```bash
resource_group_name=$(terraform output -raw resource_group_name)

az aks list \
  --resource-group $resource_group_name \
  --query "[].{\"K8s cluster name\":name}" \
  --output table
```

```bash
echo "$(terraform output kube_config)" > ./azurek8s

cat ./azurek8s
export KUBECONFIG=./azurek8s
kubectl get nodes
```

### Delete AKS resources

```bash
terraform plan -destroy -out main.destroy.tfplan
```
### Delete service principal

```bash
sp=$(terraform output -raw sp)
az ad sp delete --id $sp
```