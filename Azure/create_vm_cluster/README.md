##  Create a Linux VM cluster in Azure using Terraform

###  Initialize Terraform

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

### Verify the results (Azure CLI)

```bash
resource_group_name=$(terraform output -raw resource_group_name)

az vm list --resource-group $resource_group_name --query "[].{\"VM Name\":name}" -o table
```

### Clean up resources

```bash
terraform plan -destroy -out main.destroy.tfplan
terraform apply main.destroy.tfplan
```