output "talosconfig" {
  description = "Talosconfig of the new cluster"
  value       = var.k8s_distribution == "talos" ? module.bootstrap_talos[0].talosconfig : ""
  sensitive   = true
}

output "controlplane_nodes" {
  description = "Internal IPs of controlplanes, needed for talosctl --nodes parameter"
  value       = module.network.controlplane_fixed_ips
}

output "worker_machine_configuration" {
  description = "Machine Configuration for worker nodes"
  value       = var.k8s_distribution == "talos" ? module.talos-config[0].worker_machine_configuration : ""
}

output "controlplane_machine_configuration" {
  description = "Machine Configuration for controlplan nodes"
  value       = var.k8s_distribution == "talos" ? module.talos-config[0].controlplane_machine_configuration : ""
}

output "os_public_network_id" {
  description = "ID of the public network"
  value       = module.network.public_network_id
}

output "os_private_network_name" {
  description = "Name of the private network"
  value       = module.network.private_network_name
}

output "os_private_network_id" {
  description = "ID of the private network"
  value       = module.network.private_network_id
}

output "os_private_network_subnet_name" {
  description = "Name of the selected private network subnet"
  value       = module.network.private_network_subnet_name
}

output "os_private_network_subnet_id" {
  description = "ID of the selected private network subnet"
  value       = module.network.private_network_subnet_id
}

output "os_private_network_subnet_cidr" {
  description = "Actual CIDR of the selected private network subnet"
  value       = module.network.private_network_subnet_cidr
}

output "os_private_network_router_name" {
  description = "Name of the managed private router, or null in existing mode"
  value       = module.network.private_network_router_name
}

output "os_ssh_keypair_name" {
  description = "Name of the created key pair"
  value       = try(openstack_compute_keypair_v2.keypair[0].name, null)
}

output "internal_security_group_name" {
  description = "Name of created internal security group"
  value       = module.network.internal_security_group_name
}

output "internal_security_group_id" {
  description = "ID of the created internal security group"
  value       = module.network.internal_security_group_id
}

output "cluster_health" {
  value = var.k8s_distribution == "talos" ? module.bootstrap_talos[0].cluster_health : null
}
