output "namepace" {
  description = "Namespace for the secret"
  value       = var.namespace
}

output "secret_name" {
  description = "Name of the secret"
  value       = var.secret_name
}

output "service_account" {
  description = "Name of the created service account"
  value       = kubernetes_service_account_v1.access_secrets.metadata[0].name
}
