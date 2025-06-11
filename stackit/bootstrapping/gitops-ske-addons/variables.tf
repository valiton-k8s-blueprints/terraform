
variable "environment" {
  default     = "development"
  type        = string
  description = "Infrastructure environment name (e.g. development, staging, production)."
}
variable "region" {
  description = "STACKIT region"
  type        = string
  default     = "eu01"
}
variable "project_id" {
  type        = string
  description = "STACKIT project ID to which the cluster is associated."
}
variable "ske_cluster_name" {
  description = "Name of the SKE cluster"
  type        = string
}
variable "ske_cluster_id" {
  description = "Internal ID of the SKE cluster"
  type        = string
}
variable "ske_cluster_version" {
  description = "Kubernetes version to use for the SKE cluster"
  type        = string
}
variable "ske_egress_adress_range" {
  description = "Egress IP range of the clusters"
  type        = string
}
variable "ske_nodepools" {
  description = "Map of attribute maps for all SKE managed node pools."
  type        = any
}


variable "addons" {
  description = "Kubernetes addons"
  type        = any
  default = {
    enable_ingress_nginx         = true
    enable_cert_manager          = true
    enable_kube_prometheus_stack = true
  }

}
# Addons Git
# Applications Git
variable "gitops_applications_repo_url" {
  description = "Url of Git repository for applications"
  type        = string
  default     = "https://github.com/valiton-k8s-blueprints/argocd"
}

variable "gitops_applications_repo_path" {
  description = "Path in the Git repository for applications and values.yaml"
  type        = string
  default     = "aws"
}

variable "gitops_applications_repo_revision" {
  description = "Git repository revision/branch/ref for applications"
  type        = string
  default     = "main"
}

variable "gitops_argocd_chart_version" {
  description = "Initial ArgoCD helm chart version to be deployed via gitOps Bridge"
  type        = string
  default     = "8.0.17"
}
variable "custom_gitops_metadata" {
  description = <<EOT
This variable can be used to place additional meta information in the ArgoCD in-cluster secret. This information is then also available in the ApplicationSets via metadata.annotation. E.g.

custom_gitops_metadata = {
  vault_data_db_connection = vault_kv_secret_v2.my_db.path
  vault_data_api_key       = vault_kv_secret_v2.api_key.path
}
EOT
  type        = any
  default     = null
}

# kube-prometheus-stack
variable "kube_prometheus_stack" {
  description = "Kube prometheus stack add-on configuration values"
  type        = any
  default     = {}
}

