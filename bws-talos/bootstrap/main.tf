locals {
  cluster_secrets = {
    namespace       = try(var.cluster_secrets.namespace, "cluster-secrets")
    secret_name     = try(var.cluster_secrets.secret_name, "cluster-secrets")
    service_account = try(var.cluster_secrets.service_account, "access-cluster-secrets")
  }

  gitops_applications_repo_url      = var.gitops_applications_repo_url
  gitops_applications_repo_revision = var.gitops_applications_repo_revision

  external_secrets_namespace = try(var.external_secrets.namespace, "external-secrets")

  kube_prometheus_stack_namespace = try(var.kube_prometheus_stack.namespace, "kube-prometheus-stack")

  cinder_csi_plugin_namespace   = try(var.cinder_csi_plugin.namespace, "cinder-csi-plugin")
  cinder_csi_plugin_volume_type = try(var.cinder_csi_plugin.volume_type, "")

  external_dns_namespace      = try(var.external_dns.namespace, "external-dns")
  external_dns_domain_filters = try(var.external_dns.domain_filters, "")
  external_dns_policy         = try(var.external_dns.policy, "")

  ingress_nginx_namespace = try(var.ingress_nginx.namespace, "ingress-nginx")

  cert_manager_namespace               = try(var.cert_manager.namespace, "cert-manager")
  cert_manager_acme_registration_email = try(var.cert_manager.acme.registration_email, "")
  cert_manager_acme_enable_http01      = try(var.cert_manager.acme.enable_http01, true) && var.addons.enable_ingress_nginx
  cert_manager_acme_enable_dns01       = try(var.cert_manager.acme.enable_dns01, true) && var.addons.enable_cert_manager_designate_webhook

  argocd_hostname = try(var.argocd.hostname, "")

  addons_metadata = merge(
    {
      excluded_applications = "{${join(",", [for key, value in var.addons : replace("${regex("enable_(.+)", key)[0]}.yaml", "_", "-") if !value])}}"

      applications_repo_url      = local.gitops_applications_repo_url
      applications_repo_revision = local.gitops_applications_repo_revision

      argocd_hostname = local.argocd_hostname

      external_secrets_namespace = local.external_secrets_namespace

      kube_prometheus_stack_namespace = local.kube_prometheus_stack_namespace

      cinder_csi_plugin_namespace   = local.cinder_csi_plugin_namespace
      cinder_csi_plugin_volume_type = local.cinder_csi_plugin_volume_type

      external_dns_namespace      = local.external_dns_namespace
      external_dns_domain_filters = local.external_dns_domain_filters
      external_dns_policy         = local.external_dns_policy

      ingress_nginx_namespace = local.ingress_nginx_namespace

      cert_manager_namespace               = local.cert_manager_namespace
      cert_manager_acme_registration_email = local.cert_manager_acme_registration_email
      cert_manager_acme_enable_http01      = local.cert_manager_acme_enable_http01
      cert_manager_acme_enable_dns01       = local.cert_manager_acme_enable_dns01

      cert_manager_designate_webhook_cloud_provider_values = yamlencode({
        certManager = {
          namespace = local.cert_manager_namespace
        }
      })

      external_secrets_openstack_credentials_cloud_provider_values = yamlencode({
        clusterSecrets = {
          serviceAccountName = local.cluster_secrets.service_account
          namespace          = local.cluster_secrets.namespace
          name               = local.cluster_secrets.secret_name
        }
        cinderCsiPlugin = {
          enabled   = var.addons.enable_cinder_csi_plugin
          namespace = local.cinder_csi_plugin_namespace
          authUrl   = var.os_auth_url
        }
        externalDns = {
          enabled   = var.addons.enable_external_dns
          namespace = local.external_dns_namespace
          authUrl   = var.os_auth_url
        }
        certManagerDesignateWebhook = {
          enabled   = var.addons.enable_cert_manager_designate_webhook
          namespace = local.cert_manager_namespace
          authUrl   = var.os_auth_url
        }
        openstackCloudControllerManager = {
          authUrl = var.os_auth_url
          loadBalancer = {
            subnetId          = var.os_private_network_subnet_id
            floatingNetworkId = var.os_public_network_id
          }
        }
      })
    },
    {
      openstack_auth_url = var.os_auth_url
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

  namespace       = local.cluster_secrets.namespace
  secret_name     = local.cluster_secrets.secret_name
  service_account = local.cluster_secrets.service_account
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
