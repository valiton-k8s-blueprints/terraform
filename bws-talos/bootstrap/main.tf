locals {
  gitops_applications_repo_url      = var.gitops_applications_repo_url
  gitops_applications_repo_revision = var.gitops_applications_repo_revision

  external_secrets_namespace = try(var.external_secrets.namespace, "external-secrets")

  kube_prometheus_stack_namespace = try(var.kube_prometheus_stack.namespace, "kube-prometheus-stack")

  cinder_csi_plugin_namespace   = try(var.cinder_csi_plugin.namespace, "cinder-csi-plugin")
  cinder_csi_plugin_secret_name = try(var.cinder_csi_plugin.secret.name, "cinder-csi-plugin-secret")

  external_dns_namespace             = try(var.external_dns.namespace, "external-dns")
  external_dns_domain_filters        = try(var.external_dns.domain_filters, "")
  external_dns_policy                = try(var.external_dns.policy, "")
  external_dns_designate_cloud_name  = try(var.external_dns.designate.cloud_name, "cloud")
  external_dns_designate_secret_name = try(var.external_dns.designate.secret_name, "external-dns-designate-secret")

  ingress_nginx_namespace            = try(var.ingress_nginx.namespace, "ingress-nginx")
  ingress_nginx_ingressclass_name    = try(var.ingress_nginx.ingressclass.name, "nginx")
  ingress_nginx_ingressclass_default = try(var.ingress_nginx.ingressclass.default, "")

  cert_manager_namespace               = try(var.cert_manager.namespace, "cert-manager")
  cert_manager_service_account_name    = try(var.cert_manager.service_account_name, "cert-manager")
  cert_manager_acme_registration_email = try(var.cert_manager.acme.registration_email, "")

  cert_manager_designate_webhook_secret_name = try(var.cert_manager_designate_webhook.secret_name, "designate-auth")

  argocd_hostname = try(var.argocd.hostname, "")

  addons_metadata = merge(
    {
      excluded_applications      = "{${join(",", [for key, value in var.addons : replace("${regex("enable_(.+)", key)[0]}.yaml", "_", "-") if !value])}}"
      applications_repo_url      = local.gitops_applications_repo_url
      applications_repo_revision = local.gitops_applications_repo_revision

      argocd_hostname = local.argocd_hostname

      external_secrets_namespace = local.external_secrets_namespace

      kube_prometheus_stack_namespace = local.kube_prometheus_stack_namespace

      cinder_csi_plugin_namespace   = local.cinder_csi_plugin_namespace
      cinder_csi_plugin_secret_name = local.cinder_csi_plugin_secret_name
      enable_cinder_csi_plugin      = var.addons.enable_cinder_csi_plugin ? "true" : "false"

      external_dns_namespace             = local.external_dns_namespace
      external_dns_domain_filters        = local.external_dns_domain_filters
      external_dns_policy                = local.external_dns_policy
      external_dns_designate_cloud_name  = local.external_dns_designate_cloud_name
      external_dns_designate_secret_name = local.external_dns_designate_secret_name
      enable_external_dns                = var.addons.enable_external_dns ? "true" : "false"

      ingress_nginx_namespace            = local.ingress_nginx_namespace
      ingress_nginx_ingressclass_name    = local.ingress_nginx_ingressclass_name
      ingress_nginx_ingressclass_default = local.ingress_nginx_ingressclass_default
      enable_ingress_nginx               = var.addons.enable_ingress_nginx ? "true" : "false"

      cert_manager_namespace                     = local.cert_manager_namespace
      cert_manager_service_account_name          = local.cert_manager_service_account_name
      cert_manager_acme_registration_email       = local.cert_manager_acme_registration_email
      cert_manager_designate_webhook_secret_name = local.cert_manager_designate_webhook_secret_name
      enable_cert_manager_designate_webhook      = var.addons.enable_cert_manager_designate_webhook
    },
    {
      cluster_secret_namespace       = module.cluster_secrets.namepace
      cluster_secret_name            = module.cluster_secrets.secret_name
      cluster_secret_service_account = module.cluster_secrets.service_account
      openstack_auth_url             = var.os_auth_url
      openstack_subnet_id            = var.os_private_network_subnet_id
      openstack_floating_network_id  = var.os_public_network_id
    }
  )

  argocd_apps = {
    applications = file("${path.module}/argocd/applications.yaml")
  }

  addons = merge(
    var.addons,
    { kubernetes_version = var.kubernetes_version },
    { cloud_provider = var.cloud_provider }
  )
}

module "cluster_secrets" {
  source = "./modules/cluster_secrets"

  os_application_credential_id     = var.os_application_credential_id
  os_application_credential_secret = var.os_application_credential_secret
}

################################################################################
# GitOps Bridge: Bootstrap
################################################################################
module "gitops_bridge_bootstrap" {
  source = "git::https://github.com/valiton-k8s-blueprints/terraform-helm-gitops-bridge.git?ref=main"

  cluster = {
    cluster_name = var.base_name
    environment  = var.environment
    metadata     = local.addons_metadata
    addons       = local.addons
  }

  apps = local.argocd_apps

  argocd = {
    chart_version = "8.0.9"
    values = [
      yamlencode({
        configs = {
          cm = {
            "application.resourceTrackingMethod" = "annotation"
            "resource.customizations"            = <<-EOF
              argoproj.io/Application:
                health.lua: |
                  hs = {}
                  hs.status = "Progressing"
                  hs.message = ""
                  if obj.status ~= nil then
                    if obj.status.health ~= nil then
                      hs.status = obj.status.health.status
                      if obj.status.health.message ~= nil then
                        hs.message = obj.status.health.message
                      end
                    end
                  end
                  return hs
EOF
          }
        }
      })
    ]
  }

  destroy_timeout = var.destroy_timeout
}
