
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
    enable_ingress_nginx                            = true
    enable_cert_manager                             = true
    enable_cert_manager_default_cert                = true
    enable_external_secrets                         = true
    enable_external_secrets_stackit_secrets_manager = true
    enable_kube_prometheus_stack                    = true
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
  default     = "stackit"
}

variable "gitops_applications_repo_revision" {
  description = "Git repository revision/branch/ref for applications"
  type        = string
  default     = "main"
}

variable "gitops_argocd_chart_version" {
  description = "Initial ArgoCD helm chart version to be deployed via gitOps Bridge"
  type        = string
  default     = "8.1.1"
}

variable "metadata_annotations" {
  description = <<EOT
This variable can be used to place additional meta information in the ArgoCD in-cluster secret. This information is then also available in the ApplicationSets via metadata.annotation. E.g.

metadata_annotations = {
  vault_data_db_connection = vault_kv_secret_v2.my_db.path
  vault_data_api_key       = vault_kv_secret_v2.api_key.path
}
EOT
  type        = any
  default     = null
}

variable "metadata_labels" {
  description = <<EOT
This variable can be used to place additional label information in the ArgoCD in-cluster secret. This information is then also available in the ApplicationSets via metadata.labels. E.g.
metadata_labels = {
  enable_my_app = "true"
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

# cert-manager
variable "cert_manager_acme_registration_email" {
  description = "In cert-manager, the email address associated with an ACME account is used for administrative notifications and is included in the ACME configuration."
  type        = string
  default     = "test@example.com"
}

variable "cert_manager_acme_stackit_project_id" {
  description = "The STACKIT project id of the project in which the SKE cluster is running and the cert-manager is installed."
  type        = string
  default     = null
}

variable "cert_manager_stackit_webhook_service_account_secret" {
  description = "The secret from the STACKIT service account, which includes the token to perform the DNS01 challenge in the configured STACKIT DNS zone."
  type        = string
  default     = "certmanager/serviceaccount"
}

variable "cert_manager_dns01_issuer_name" {
  description = "The name of the issuer that ArgoCD should use to create the DNS01 challenge issuer."
  type        = string
  default     = "letsencrypt-dns01"
}

variable "cert_manager_http01_issuer_name" {
  description = "The name of the issuer that ArgoCD should use to create the http01 challenge issuer."
  type        = string
  default     = "letsencrypt-http01"
}

variable "cert_manager_use_default_cert" {
  description = "When it is set to true, cert manager we use a default cert."
  type        = bool
  default     = true
}

variable "cert_manager_default_cert_solver_type" {
  description = "ACME challenge solver type for the default certificate"
  type        = string
  default     = "dns01"

  validation {
    condition     = contains(["dns01", "http01"], var.cert_manager_default_cert_solver_type)
    error_message = "solver_type must be either 'dns01' or 'http01'."
  }
}


variable "cert_manager_default_cert_domain_list" {
  description = "When `enable_cert_manager_default_cert` is set to true, cert-manager will use these domains for the default certificate."
  type        = list(any)
  default     = ["test.example.com", "*.test.example.com"]
}

variable "cert_manager_default_cert_name" {
  description = "When `enable_cert_manager_default_cert` is set to true, cert-manager will use this name for the default certificate."
  type        = string
  default     = "letsencrypt-default-cert"
}

variable "cert_manager_default_cert_namespace" {
  description = "When `enable_cert_manager_default_cert` is set to true, the bootstrapper will create this namespace and the  cert-manager will put the default certificate into  this namespace."
  type        = string
  default     = "myapp"
}

variable "cert_manager_stackit_service_account_email" {
  description = "The e-mail address for the STACKIT service account used by the Cert Manager (e.g. DNS01 challenge in the STACKIT dns zone). Note: The service account must exist beforehand and in the case of DNS01 Challenge it should also already have permission for dns.admin or dns.reader."
  type        = string
  default     = "example@sa.stackit.cloud"
}

# external-secrets
variable "external_secrets" {
  description = "ExternalSecrets add-on configuration values"
  type        = any
  default     = {}
}

variable "external_secrets_stackit_secrets_manager_config" {
  description = "Configuration parameters used by externalSecrets together with STACKIT secrets manager"
  type        = any
  default     = {}

}


