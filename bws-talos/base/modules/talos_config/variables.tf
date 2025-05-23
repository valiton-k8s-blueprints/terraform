variable "cluster_name" {
  description = "Name of the cluster"
  default     = "my-cluster"
}

variable "kube_api_external_ip" {
  description = "External IP of Kube API"
  default     = "1.2.3.4"
}

variable "kube_api_external_port" {
  description = "External port of Kube API"
  type        = number
  default     = 6443
}

variable "kubernetes_version" {
  description = "Kubernetes version to install"
  default     = "v1.32.2"
}

variable "os_ccm_version" {
  description = "Openstack cloud controller manager version"
  default     = "v1.32.0"
}

variable "os_auth_url" {
  description = "Openstack Keystone url"
  default     = "https://dashboard.example.com:5000"
}

variable "os_application_credential_id" {
  description = "Openstack application credentials ID"
  default     = ""
}

variable "os_application_credential_secret" {
  description = "Openstack application credentials secret"
  default     = ""
}

variable "os_user_name" {
  description = "Openstack user name"
  default     = ""
}

variable "public_network_id" {
  description = "ID of the public network"
  type        = string
  default     = "dfae-3345"
}

variable "private_network_subnet_id" {
  description = "ID of the private subnet"
  type        = string
  default     = "dfae-3345"
}

variable "talos_secrets" {
  description = "Object of secrets generated with talosctl gen secrets"
}

variable "pod_security_exemptions_namespaces" {
  description = "List of namespaces exempt from pod security configuration"
  default     = "kube-system"
}
