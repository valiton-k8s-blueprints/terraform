variable "k8s_distribution" {
  description = "Kubernetes distribution, one of 'talos', 'k0s'"
  type        = string
  validation {
    condition     = contains(["talos", "k0s"], var.k8s_distribution)
    error_message = "Valid values for k8s_distribution are talos and k0s."
  }
}

variable "base_name" {
  description = "Name of your base infrastructure."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.base_name))
    error_message = "The base_name must only contain lowercase letters, numbers, and dashes."
  }
}

variable "controlplane_machine_configuration" {
  description = "Talos controlplane configuration object"
  type        = any
}

variable "worker_machine_configuration" {
  description = "Talos worker configuration object"
  type        = any
}

variable "client_configuration" {
  description = "Talos client configuration object"
  type        = any
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
}

variable "controlplane_count" {
  description = "Number of controlplane nodes"
  type        = number
}

variable "kube_api_external_ip" {
  description = "External IP of Kube API"
  type        = string
}

variable "controlplane_names" {
  description = "Names of the controlplane nodes"
  type        = list(string)
}

variable "worker_names" {
  description = "Names of the worker nodes"
  type        = list(string)
}
