output "worker_machine_configuration" {
  description = "Talos configuration for worker nodes"
  value       = data.talos_machine_configuration.worker.machine_configuration
  sensitive   = true
}

output "controlplane_machine_configuration" {
  description = "Talos configuration for controlplane nodes"
  value       = data.talos_machine_configuration.controlplane.machine_configuration
  sensitive   = true
}

output "talos_client_crt" {
  description = "Talos client certificate"
  value       = tls_locally_signed_cert.talos_client_cert.cert_pem
}

output "talos_client_key" {
  description = "Talos client key"
  value       = tls_private_key.talos_client_key.private_key_pem
}
