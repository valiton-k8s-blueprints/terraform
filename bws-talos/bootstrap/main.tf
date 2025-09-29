locals {
  cluster_secrets = {
    namespace       = try(var.cluster_secrets.namespace, "cluster-secrets")
    secret_name     = try(var.cluster_secrets.secret_name, "cluster-secrets")
    service_account = try(var.cluster_secrets.service_account, "access-cluster-secrets")
  }

  addons = var.metadata_labels

  metadata_annotations = merge(
    var.metadata_annotations,
    {
      applications_repo_url      = var.gitops_applications_repo_url
      applications_repo_path     = var.gitops_applications_repo_path
      applications_repo_revision = var.gitops_applications_repo_revision

      cluster_secret_namespace       = local.cluster_secrets.namespace
      cluster_secret_name            = local.cluster_secrets.secret_name
      cluster_secret_service_account = local.cluster_secrets.service_account
    }
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

  depends_on = [module.cluster_secrets]

  cluster = {
    cluster_name = var.base_name
    environment  = var.environment
    metadata     = local.metadata_annotations
    addons       = local.addons
  }

  apps = var.custom_argocd_apps != null ? var.custom_argocd_apps : {
    applications = templatefile("${path.module}/argocd/applications.yaml", {
      cluster_selector = jsonencode(var.argocd_applications_selector)
    })
  }

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
