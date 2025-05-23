variable "environment" {
  description = "Infrastructure environment name (e.g. development, staging, production)."
  type        = string
}

variable "cloud_provider" {
  description = "Name of the cloud provider"
  default     = "bws"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}

variable "base_name" {
  description = "Name of your base infrastructure."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.base_name))
    error_message = "The base_name must only contain lowercase letters, numbers, and dashes."
  }
}

variable "os_public_network_id" {
  description = "ID of the Openstack public network"
}

variable "os_private_network_subnet_id" {
  description = "ID of the private network"
}

variable "os_auth_url" {
  description = "Openstack keystone url"
}

variable "os_application_credential_id" {
  description = "Openstack application credentials ID"
}

variable "os_application_credential_secret" {
  description = "Openstack application credentials secret"
}

variable "addons" {
  description = "Kubernetes addons"
  type        = any
}

# Applications Git
variable "gitops_applications_repo_url" {
  description = "Url of Git repository for applications"
  type        = string
}

variable "gitops_applications_repo_revision" {
  description = "Git repository revision/branch/ref for applications"
  type        = string
}

variable "destroy_timeout" {
  description = "Time to wait after uninstalling applications in seconds"
  type        = number
}

# Applications
variable "external_dns" {
  description = "External DNS add-on configuration values"
  type        = any
  default     = {}
}

variable "external_secrets" {
  description = "External Secrets add-on configuration values"
  type        = any
  default     = {}
}

variable "ingress_nginx" {
  description = "Ingress Nginx add-on configuration values"
  type        = any
  default     = {}
}

variable "kube_prometheus_stack" {
  description = "Kube prometheus stack add-on configuration values"
  type        = any
  default     = {}
}

variable "cinder_csi_plugin" {
  description = "Cinder csi plugin add-on configuration values"
  type        = any
  default     = {}
}

variable "cert_manager" {
  description = "Cert manager add-on configuration values"
  type        = any
  default = {
    acme = {
      registration_email = ""
    }
  }
}

variable "cert_manager_designate_webhook" {
  description = "Cert manager webhook for ACME DNS-01 challenge with Designate"
  type        = any
  default     = {}
}

variable "argocd" {
  description = "ArgoCD"
  type        = any
  default     = {}
}
