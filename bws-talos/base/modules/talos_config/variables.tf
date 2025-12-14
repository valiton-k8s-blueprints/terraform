variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}

variable "kube_api_external_ip" {
  description = "External IP of Kube API"
  type        = string
}

variable "kube_api_external_port" {
  description = "External port of Kube API"
  type        = number
}

variable "kubernetes_version" {
  description = "Kubernetes version to install"
  type        = string
}

variable "os_ccm_version" {
  description = "Openstack cloud controller manager version"
  type        = string
}

variable "os_auth_url" {
  description = "Openstack Keystone url"
  type        = string
}

variable "os_application_credential_id" {
  description = "Openstack application credentials ID"
  type        = string
}

variable "os_application_credential_secret" {
  description = "Openstack application credentials secret"
  type        = string
  default     = ""
}

variable "os_user_name" {
  description = "Openstack user name"
  type        = string
}

variable "public_network_id" {
  description = "ID of the public network"
  type        = string
}

variable "private_network_subnet_id" {
  description = "ID of the private subnet"
  type        = string
}

variable "talos_secrets" {
  description = "Object of secrets generated with talosctl gen secrets"
  type        = any
}

variable "pod_security_exemptions_namespaces" {
  description = "List of namespaces exempt from pod security configuration"
  type        = list(string)
}
