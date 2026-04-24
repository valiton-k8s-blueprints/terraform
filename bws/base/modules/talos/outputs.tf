output "talosconfig" {
  description = "Talosconfig of the new cluster"
  value       = data.talos_client_configuration.talos.talos_config
  sensitive   = true
}

output "cluster_health" {
  value = helm_release.openstack_cloud_controller_manager.status
}
