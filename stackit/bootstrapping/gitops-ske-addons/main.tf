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

  ske_addons = {
    enable_argocd                = try(var.addons.enable_argocd, true)
    enable_ingress_nginx         = try(var.addons.enable_ingress_nginx, false)
    enable_cert_manager          = try(var.addons.enable_cert_manager, false)
    enable_kube_prometheus_stack = try(var.addons.enable_kube_prometheus_stack, false)
    enable_metrics_server        = try(var.addons.enable_kube_prometheus_stack, false)
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
    { cloud_provider = "aws" },
    var.custom_gitops_metadata
  )

  argocd_apps = {
    applications = file("${path.module}/argocd/applications.yaml")
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

  apps = local.argocd_apps
}
