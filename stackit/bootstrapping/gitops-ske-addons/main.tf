
locals {
  region = var.region

  environment = var.environment

  project_id = var.project_id

  ske_cluster_name        = var.ske_cluster_name
  ske_cluster_id          = var.ske_cluster_id
  ske_egress_adress_range = var.ske_egress_adress_range
  ske_cluster_version     = var.ske_cluster_version
  ske_nodepools           = var.ske_nodepools

  gitops_applications_repo_url      = var.gitops_applications_repo_url
  gitops_applications_repo_path     = var.gitops_applications_repo_path
  gitops_applications_repo_revision = var.gitops_applications_repo_revision

  gitops_argocd_chart_version = var.gitops_argocd_chart_version

  kube_prometheus_stack_namespace = try(var.kube_prometheus_stack.namespace, "kube-prometheus-stack")
  external_secrets_namespace = try(var.external_secrets.namespace, "external-secrets")

  stackit_sm_user = try(var.external_secrets_stackit_secrets_manager_config.sm_user, "undefined")
  stackit_sm_secret_name = try(var.external_secrets_stackit_secrets_manager_config.sm_secret_name, "vault-userpass-creds")
  stackit_sm_secret_namespace = try(var.external_secrets_stackit_secrets_manager_config.sm_secret_namespace, "external-secrets")


  custom_gitops_metadata = var.custom_gitops_metadata


  ske_addons = {
    enable_argocd                                   = try(var.addons.enable_argocd, true)
    enable_ingress_nginx                            = try(var.addons.enable_ingress_nginx, false)
    enable_cert_manager                             = try(var.addons.enable_cert_manager, false)
    enable_kube_prometheus_stack                    = try(var.addons.enable_kube_prometheus_stack, false)
    enable_metrics_server                           = try(var.addons.enable_metrics_server, false)
    enable_external_secrets                         = try(var.addons.enable_external_secrets, false)
    enable_external_secrets_stackit_secrets_manager = try(var.addons.enable_external_secrets_stackit_secrets_manager, false)
  }


  addons = merge(
    local.ske_addons,
    { kubernetes_version = local.ske_cluster_version },
  )

  addons_metadata = merge(
    {
      ske_cluster_name     = local.ske_cluster_name
      region               = local.region
      project_id           = local.project_id
      base_nodepool_labels = jsonencode(local.ske_nodepools[0].labels)
    },
    {
      applications_repo_url      = local.gitops_applications_repo_url
      applications_repo_path     = local.gitops_applications_repo_path
      applications_repo_revision = local.gitops_applications_repo_revision
    },
    { kube_prometheus_stack_namespace = local.kube_prometheus_stack_namespace },
    { external_secrets_namespace = local.external_secrets_namespace },
    { 
      stackit_sm_user = local.stackit_sm_user
      stackit_sm_secret_name = local.stackit_sm_secret_name
      stackit_sm_secret_namespace = local.stackit_sm_secret_namespace
    },
    { cloud_provider = "stackit" },
    local.custom_gitops_metadata,
  )

  argocd_apps = {
    applications = file("${path.module}/argocd/applications.yaml")
  }
}


resource "kubernetes_namespace_v1" "external_secrets" {
  count = (local.ske_addons.enable_external_secrets && local.ske_addons.enable_external_secrets_stackit_secrets_manager) ? 1 : 0

  metadata {
    name = "external-secrets"
  }
}

resource "kubernetes_secret" "vault_userpass_creds" {
  count = (local.ske_addons.enable_external_secrets && local.ske_addons.enable_external_secrets_stackit_secrets_manager) ? 1 : 0

  metadata {
    name      = local.stackit_sm_secret_name
    namespace = local.stackit_sm_secret_namespace
  }

  data = {
    username = local.stackit_sm_user
    password = var.external_secrets_stackit_secrets_manager_config.sm_password
  }

  type = "Opaque"

  depends_on = [
    kubernetes_namespace_v1.external_secrets
  ]
}

################################################################################
# GitOps Bridge: Bootstrap
################################################################################
module "gitops_bridge_bootstrap" {
  source = "git::https://github.com/valiton-k8s-blueprints/terraform-helm-gitops-bridge?ref=main"

  cluster = {
    cluster_name = local.ske_cluster_name
    environment  = local.environment
    metadata     = local.addons_metadata
    addons       = local.addons
  }

  apps = local.argocd_apps
}
