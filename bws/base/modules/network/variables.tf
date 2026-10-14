variable "name_prefix" {
  description = "Prefix to add to names of created resources"
  type        = string
}

variable "kube_api_external_ip" {
  description = "Floating public IP for Kubernetes and Talos API. Needs to be created manually"
  type        = string
}

variable "kube_api_external_port" {
  description = "External port to expose Kubernetes API server"
  type        = number
}

variable "os_public_network_name" {
  description = "Public network name"
  type        = string
}

variable "os_private_network_name" {
  description = "Name of the created private network, prefixed with name_prefix; also used in cluster security-group naming"
  type        = string

  validation {
    condition     = trimspace(var.os_private_network_name) != ""
    error_message = "The private network name must not be empty."
  }
}

variable "os_existing_private_network" {
  description = "Existing private network and IPv4 subnet to reuse; null creates networking"
  type = object({
    network_name = string
    subnet_name  = string
  })
  default = null

  validation {
    condition = var.os_existing_private_network == null ? true : (
      can(regex("\\S", trimspace(var.os_existing_private_network.network_name))) &&
      can(regex("\\S", trimspace(var.os_existing_private_network.subnet_name)))
    )
    error_message = "Existing networking requires non-null, nonblank network_name and subnet_name."
  }
}

variable "os_private_network_subnet_name" {
  description = "Name of the created private subnet; empty derives it from name_prefix and os_private_network_name"
  type        = string
  default     = ""
}

variable "os_private_network_cidr" {
  description = "Optional managed IPv4 CIDR; empty generates a CIDR in managed mode and reads the actual subnet in existing mode"
  type        = string
  default     = ""

  validation {
    condition     = var.os_private_network_cidr == "" || can(cidrnetmask(var.os_private_network_cidr))
    error_message = "The private network CIDR must be empty or a valid IPv4 CIDR."
  }
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
}

variable "controlplane_count" {
  description = "Number of controlplane nodes"
  type        = number
}

variable "enable_talos_api" {
  type = bool
}

variable "enable_ssh_bastion" {
  type = bool
}

variable "enable_k0s_api" {
  type = bool
}

variable "enable_konnectivity" {
  type = bool
}

variable "enable_keystone_auth" {
  type = bool
}

variable "keystone_auth_port" {
  description = "Port to expose keystone auth"
  type        = number
}
