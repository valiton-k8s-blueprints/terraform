locals {
  kube_prometheus_stack_namespace = try(var.kube_prometheus_stack.namespace, "kube-prometheus-stack")
  cinder_csi_plugin_namespace     = try(var.cinder_csi_plugin.namespace, "cinder-csi-plugin")

  addons = {
    enable_argocd                         = try(var.addons.enable_argocd, true)
    enable_external_secrets               = try(var.addons.enable_external_secrets, false) || try(var.addons.enable_cinder_csi_plugin, false) || try(var.addons.enable_external_dns, false) || try(var.addons.enable_cert_manager_designate_webhook, false)
    enable_kube_prometheus_stack          = try(var.addons.enable_kube_prometheus_stack, false)
    enable_metrics_server                 = try(var.addons.enable_metrics_server, false)
    enable_cinder_csi_plugin              = try(var.addons.enable_cinder_csi_plugin, false)
    enable_external_dns                   = try(var.addons.enable_external_dns, false)
    enable_ingress_nginx                  = try(var.addons.enable_ingress_nginx, false)
    enable_cert_manager                   = try(var.addons.enable_cert_manager, false) || try(var.addons.enable_cert_manager_designate_webhook, false)
    enable_cert_manager_designate_webhook = try(var.addons.enable_cert_manager_designate_webhook, false)
  }

  pod_security_exemptions_namespaces = compact([
    local.addons.enable_kube_prometheus_stack ? local.kube_prometheus_stack_namespace : "",
    local.addons.enable_cinder_csi_plugin ? local.cinder_csi_plugin_namespace : ""
  ])
}
