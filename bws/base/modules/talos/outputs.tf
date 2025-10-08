output "talosconfig" {
  description = "Talosconfig of the new cluster"
  value       = data.talos_client_configuration.talos.talos_config
  sensitive   = true
}

output "talos_cluster_health" {
  value = data.talos_cluster_health.talos
}
