variable "name_prefix" {
  description = "Prefix to add to names of created resources"
  default     = "cluster"
}

variable "kube_api_external_ip" {
  description = "Floating public IP for Kubernetes and Talos API. Needs to be created manually"
  default     = ""
}

variable "kube_api_external_port" {
  description = "External port to expose Kubernetes API server"
  type        = number
  default     = 6443
}

variable "os_public_network_name" {
  description = "Public network name"
  default     = "Public1"
}

variable "os_private_network_name" {
  description = "Private network name"
  default     = "private-network"
}

variable "os_private_network_cidr" {
  description = "IP Range (CIDR) of the private network"
  default     = "10.10.0.0/24"
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "controlplane_count" {
  description = "Number of controlplane nodes"
  type        = number
  default     = 3
}
