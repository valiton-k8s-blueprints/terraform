variable "namespace" {
  description = "Namespace to create the secrets"
  default     = "cluster-secrets"
}

variable "secret_name" {
  description = "Name for the secrets"
  default     = "cluster-secrets"
}

variable "os_application_credential_id" {
  description = "Openstack application credentials ID"
  default     = ""
}

variable "os_application_credential_secret" {
  description = "Openstack application credentials secret"
  default     = ""
}
