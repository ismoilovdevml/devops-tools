output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

# The VM resource here is named "k8s-master", and azurerm_linux_virtual_machine
# has no public_ip_address attribute -- read the IP off the public IP resource.
output "public_ip_address" {
  value = azurerm_public_ip.my_terraform_public_ip.ip_address
}

output "vm_name" {
  value = azurerm_linux_virtual_machine.k8s-master.name
}
