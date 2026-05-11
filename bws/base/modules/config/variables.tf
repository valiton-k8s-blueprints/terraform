variable "os_ccm_version" {
  description = "Openstack cloud controller manager version"
  type        = string
}

variable "os_auth_url" {
  description = "Openstack Keystone url"
  type        = string
}

variable "os_user_name" {
  description = "Openstack user name"
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

variable "os_subnet_id" {
  description = "ID of the created private subnet"
  type        = string
}

variable "os_floating_network_id" {
  description = "ID of the public network"
  type        = string
}

variable "kube_api_external_ip" {
  description = "Floating public IP for Kubernetes and Talos API. Needs to be created manually"
  type        = string
}

variable "keystone_auth_port" {
  description = "Nodeport to expose keystone auth"
  type        = number
}
