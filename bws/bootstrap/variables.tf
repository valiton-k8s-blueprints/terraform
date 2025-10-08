variable "base_name" {
  description = "Name of your base infrastructure."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.base_name))
    error_message = "The base_name must only contain lowercase letters, numbers, and dashes."
  }
}

variable "environment" {
  description = "Infrastructure environment name (e.g. development, staging, production)."
  type        = string
}

variable "os_application_credential_id" {
  description = "Openstack application credentials ID"
}

variable "os_application_credential_secret" {
  description = "Openstack application credentials secret"
}

variable "cluster_secrets" {
  description = "Configure namespace, secret name and service account name for Openstack secret"
  type        = any
  default     = {}
}

variable "metadata_annotations" {
  description = "Values to be used in ApplicationSet definitions and stored as annotations of the cluster secret"
  type        = map(string)
  default     = {}
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

# Applications Git
variable "gitops_applications_repo_url" {
  description = "Url of Git repository for applications"
  type        = string
}

variable "gitops_applications_repo_path" {
  description = "Path in the Git repository for applications and values.yaml"
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
