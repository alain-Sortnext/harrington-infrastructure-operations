# -----------------------------------------------------------------
# Harrington Capital plc -- Terraform Outputs
# -----------------------------------------------------------------

output "resource_group_prod_id" {
  description = "Production resource group ID"
  value       = azurerm_resource_group.prod.id
}

output "resource_group_dev_id" {
  description = "Dev resource group ID"
  value       = azurerm_resource_group.dev.id
}

output "vnet_id" {
  description = "Production VNet ID"
  value       = azurerm_virtual_network.prod.id
}

output "vnet_address_space" {
  description = "VNet address space"
  value       = azurerm_virtual_network.prod.address_space
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value = {
    app  = azurerm_subnet.app.id
    data = azurerm_subnet.data.id
    mgmt = azurerm_subnet.mgmt.id
  }
}

output "dc01_public_ip" {
  description = "Public IP address of Domain Controller"
  value       = azurerm_public_ip.dc01.ip_address
}

output "app01_public_ip" {
  description = "Public IP address of app server"
  value       = azurerm_public_ip.app01.ip_address
}

output "mon01_public_ip" {
  description = "Public IP address of monitoring server"
  value       = azurerm_public_ip.mon01.ip_address
}

output "dc01_private_ip" {
  description = "Private IP of Domain Controller"
  value       = azurerm_network_interface.dc01.private_ip_address
}

output "vm_names" {
  description = "All VM names deployed"
  value = [
    azurerm_windows_virtual_machine.dc01.name,
    azurerm_linux_virtual_machine.app01.name,
    azurerm_linux_virtual_machine.mon01.name,
  ]
}
