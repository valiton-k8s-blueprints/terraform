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

output "os_private_network_subnet_id" {
  description = "ID of the created private network subnet"
  value       = module.network.private_network_subnet_id
}

output "cluster_health" {
  value = var.k8s_distribution == "talos" ? module.bootstrap_talos[0].cluster_health : null
}
