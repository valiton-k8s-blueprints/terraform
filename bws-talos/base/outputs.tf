output "talosconfig" {
  description = "Talosconfig of the new cluster"
  value       = data.talos_client_configuration.talos.talos_config
  sensitive   = true
}

output "controlplane_nodes" {
  description = "Internal IPs of controlplanes, needed for talosctl --nodes parameter"
  value       = module.network.controlplane_fixed_ips
}

output "worker_machine_configuration" {
  description = "Machine Configuration for worker nodes"
  value       = module.talos-config.worker_machine_configuration
}

output "controlplane_machine_configuration" {
  description = "Machine Configuration for controlplan nodes"
  value       = module.talos-config.controlplane_machine_configuration
}

output "os_public_network_id" {
  description = "ID of the public network"
  value       =  module.network.public_network_id
}

output "os_private_network_subnet_id" {
  description = "ID of the created private network subnet"
  value       = module.network.private_network_subnet_id
}

output "talos_cluster_health" {
  value = data.talos_cluster_health.talos
}

output "x_download_kubeconfig" {
  description = "Terminal Setup"
  value       = <<-EOT
    terraform output -raw talosconfig > talosconfig
    talosctl --talosconfig ./talosconfig --nodes ${module.network.controlplane_fixed_ips[0]} kubeconfig
    EOT
}
