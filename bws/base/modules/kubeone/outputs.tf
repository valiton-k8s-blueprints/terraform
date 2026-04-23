output "x_kubeconfig" {
  description = "Get kubeconfig of cluster"
  value       = <<-EOT
    ls -al ${var.cluster_name}-kubeconfig
    EOT
}
