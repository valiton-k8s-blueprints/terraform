variable "namespace" {
  description = "Namespace to create the secrets"
  type        = string
}

variable "secret_name" {
  description = "Name for the secrets"
  type        = string
}

variable "service_account" {
  description = "Name for the service account"
  type        = string
}

variable "os_application_credential_id" {
  description = "Openstack application credentials ID"
  type        = string
}

variable "os_application_credential_secret" {
  description = "Openstack application credentials secret"
  type        = string
}

variable "dynamic_worker_cloud_init" {
  description = "Cloud init for dynamic workers"
  type        = string
  default     = ""
}
