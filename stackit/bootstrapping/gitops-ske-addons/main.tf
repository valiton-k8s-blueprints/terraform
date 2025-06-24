
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
  external_secrets_namespace      = try(var.external_secrets.namespace, "external-secrets")

  stackit_sm_user             = try(var.external_secrets_stackit_secrets_manager_config.sm_user, "undefined")
  stackit_sm_secret_name      = try(var.external_secrets_stackit_secrets_manager_config.sm_secret_name, "vault-userpass-creds")
  stackit_sm_secret_namespace = try(var.external_secrets_stackit_secrets_manager_config.sm_secret_namespace, "external-secrets")
  stackit_sm_instance_id      = try(var.external_secrets_stackit_secrets_manager_config.sm_instance_id, "undefined")

  cert_manager_acme_registration_email                = var.cert_manager_acme_registration_email
  cert_manager_stackit_webhook_service_account_secret = var.cert_manager_stackit_webhook_service_account_secret
  cert_manager_stackit_service_account_emyail         = var.cert_manager_stackit_service_account_email
  cert_manager_dns01_issuer_name                      = var.cert_manager_dns01_issuer_name
  cert_manager_http01_issuer_name                     = var.cert_manager_http01_issuer_name
  cert_manager_default_cert_domain_list               = var.cert_manager_default_cert_domain_list
  cert_manager_default_cert_solver_type               = var.cert_manager_default_cert_solver_type
  cert_manager_default_cert_name                      = var.cert_manager_default_cert_name
  cert_manager_default_cert_namespace                 = var.cert_manager_default_cert_namespace


  custom_gitops_metadata = var.custom_gitops_metadata


  ske_addons = {
    enable_argocd                                   = try(var.addons.enable_argocd, true)
    enable_ingress_nginx                            = try(var.addons.enable_ingress_nginx, false)
    enable_cert_manager                             = try(var.addons.enable_cert_manager, false)
    enable_cert_manager_default_cert                = try(var.addons.enable_cert_manager_default_cert, false)
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
      stackit_sm_user             = local.stackit_sm_user
      stackit_sm_secret_name      = local.stackit_sm_secret_name
      stackit_sm_secret_namespace = local.stackit_sm_secret_namespace
      stackit_sm_instance_id      = local.stackit_sm_instance_id
    },
    {
      cert_manager_stackit_webhook_service_account_secret = local.cert_manager_stackit_webhook_service_account_secret
      cert_manager_acme_registration_email                = local.cert_manager_acme_registration_email
      cert_manager_dns01_issuer_name                      = var.cert_manager_dns01_issuer_name
      cert_manager_http01_issuer_name                     = var.cert_manager_http01_issuer_name
      cert_manager_default_cert_domain_list               = jsonencode(local.cert_manager_default_cert_domain_list)
      cert_manager_default_cert_solver_type               = local.cert_manager_default_cert_solver_type
      cert_manager_default_cert_name                      = local.cert_manager_default_cert_name
      cert_manager_default_cert_namespace                 = local.cert_manager_default_cert_namespace
    },
    { cloud_provider = "stackit" },
    local.custom_gitops_metadata,
  )

  argocd_apps = {
    applications = file("${path.module}/argocd/applications.yaml")
  }
}


################################################################################
# STACKIT Secrets Manager +  ExternalSecrets 
################################################################################
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
# Cert Manager - Webhook Secret with STACKIT service acoount for DNS01 challenge
# https://docs.stackit.cloud/stackit/en/how-to-use-stackit-dns-for-dns01-to-act-as-a-dns01-acme-issuer-with-cert-manager-152633984.html
################################################################################
resource "time_rotating" "rotate" {
  count = (local.ske_addons.enable_cert_manager && local.ske_addons.enable_external_secrets) ? 1 : 0

  rotation_days = 80
}

resource "stackit_service_account_access_token" "cert_manager_sa_token" {
  count                 = (local.ske_addons.enable_cert_manager && local.ske_addons.enable_external_secrets) ? 1 : 0
  project_id            = local.project_id
  service_account_email = local.cert_manager_stackit_service_account_email
  ttl_days              = 180

  rotate_when_changed = {
    rotation = time_rotating.rotate[count.index].id
  }
}


resource "vault_kv_secret_v2" "cert_manager_webhook_secret" {
  count               = (local.ske_addons.enable_cert_manager && local.ske_addons.enable_external_secrets) ? 1 : 0
  mount               = local.stackit_sm_instance_id
  name                = local.cert_manager_stackit_webhook_service_account_secret
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      token_id = stackit_service_account_access_token.cert_manager_sa_token[count.index].access_token_id,
      token    = stackit_service_account_access_token.cert_manager_sa_token[count.index].token,
    }
  )
}

resource "kubernetes_namespace_v1" "cert_manager_default_certificate" {
  count = (local.ske_addons.enable_cert_manager_default_cert && local.ske_addons.enable_cert_manager) ? 1 : 0

  metadata {
    name = local.cert_manager_default_cert_namespace
  }
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

  argocd = {
    chart_version = "8.1.1"
  }


  apps = local.argocd_apps
}
