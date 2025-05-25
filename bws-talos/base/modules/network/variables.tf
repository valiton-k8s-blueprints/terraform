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
  description = "Private network name"
  type        = string
}

variable "os_private_network_cidr" {
  description = "IP Range (CIDR) of the private network"
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
