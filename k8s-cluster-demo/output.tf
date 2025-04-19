output "resource_group_name" {
  value = module.resource_group.name
}

output "virtual_network_name" {
  value = module.virtual_network.vnet_name
}
output "id" {
  description = "The ID of the resource group"
  value       = module.resource_group.id
}

output "vmss_public_ip_fqdn" {
  value = azurerm_public_ip.vmss.fqdn
}

/*
To use count in the outputs for resources that are created with count,
 you can loop through the instances and output their values dynamically. 
 In Terraform, you can use the for expression to iterate over the 
 instances and generate a list of outputs.
 */
output "jumpbox_public_ip_fqdns" {
  description = "The fully qualified domain names (FQDNs) of the jumpbox public IPs"
  value       = [for ip in azurerm_public_ip.jumpbox : ip.fqdn]
}

output "jumpbox_public_ips" {
  description = "The public IP addresses of the jumpbox instances"
  value       = [for ip in azurerm_public_ip.jumpbox : ip.ip_address]
}
/*

output "jumpbox_public_ip_fqdn" {
  description = "The fully qualified domain name (FQDN) of the jumpbox public IP"
  value       = azurerm_public_ip.jumpbox[0].fqdn
}

output "jumpbox_public_ip" {
  description = "The public IP address of the jumpbox"
  value       = azurerm_public_ip.jumpbox[0].ip_address
}

output "jumpbox_public_ip_fqdn" {
  value = azurerm_public_ip.jumpbox.fqdn
}

output "jumpbox_public_ip" {
  value = azurerm_public_ip.jumpbox.ip_address
}
*/

output "ssh_private_key" {
  value     = azapi_resource_action.ssh_public_key_gen.output.privateKey
  sensitive = true
}

output "kubernetes_cluster_name" {
  description = "The name of the Kubernetes cluster"
  value       = module.kubernetes_cluster.kubernetes_cluster_name
}