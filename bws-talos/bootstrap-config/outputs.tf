output "addons" {
  description = "List of addons"
  value       = local.addons
}

output "pod_security_exemptions_namespaces" {
  description = "List of namespaces that need to be excluded from pod security"
  value       = local.pod_security_exemptions_namespaces
}

output "kube_prometheus_stack_namespace" {
  value = local.kube_prometheus_stack_namespace
}

output "cinder_csi_plugin_namespace" {
  value = local.cinder_csi_plugin_namespace
}
