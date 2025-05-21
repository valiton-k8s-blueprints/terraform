variable "base_name" {
  description = "Name of your base infrastructure."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.base_name))
    error_message = "The base_name must only contain lowercase letters, numbers, and dashes."
  }
}

variable "os_public_network_name" {
  description = "Name of the Openstack public network"
}

variable "os_private_network_name" {
  description = "Name of the private network, will be prefixed with base_name"
  default     = "private-network"
}

variable "os_private_network_cidr" {
  description = "Private network CIDR, if empty a random CIDR will be chosen, 10.244.0.0/16 and 10.96.0.0/12 are used by Talos."
  type        = string
  default     = ""
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

variable "os_user_name" {
  description = "Openstack user name"
}

variable "talos_secrets" {
  description = "Object of secrets generated with talosctl gen secrets"
}

variable "worker_instance_flavor" {
  description = "Instance flavor for worker nodes"
}

variable "worker_volume_type" {
  description = "BWS volume type for worker nodes"
}

variable "worker_volume_size" {
  description = "Size in GB of the disk of worker nodes"
}

variable "controlplane_instance_flavor" {
  description = "Instance flavor for controlplane nodes"
}

variable "controlplane_volume_type" {
  description = "BWS volume type for controlplane nodes"
}

variable "controlplane_volume_size" {
  description = "Size in GB of the disk of controlplane nodes"
}

variable "image_name" {
  description = "Name of the Talos image in your BWS project"
}

variable "kube_api_external_ip" {
  description = "External floating IP to expose Kubernetes API"
  type        = string
}

variable "kube_api_external_port" {
  description = "Port to expose Kubernetes API"
  type        = number
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}

variable "openstack_ccm_version" {
  description = "Openstack cloud controller mananger version"
  type        = string
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
}

variable "controlplane_count" {
  description = "Number of controlplane nodes"
  type        = number
}

variable "pod_security_exemptions_namespaces" {
  description = "List of namespaces for pod security exemption"
}
