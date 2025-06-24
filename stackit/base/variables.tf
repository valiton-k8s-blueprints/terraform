variable "environment" {
  default     = "development"
  type        = string
  description = "Infrastructure environment name (e.g. development, staging, production)."
}
variable "project_id" {
  type        = string
  description = "STACKIT project ID to which the cluster is associated."
}
variable "base_name" {
  description = "Name of your base infrastructure cluster."
  type        = string
  default     = "my-project"

  validation {
    condition     = length(split("", var.base_name)) <= 15
    error_message = "The base name must be at most 15 characters (runes) long."
  }
}
variable "availability_zones" {
  description = "Number of availability zones"
  type        = list(string)
  default     = ["eu01-1", "eu01-2", "eu01-3", "eu01-m"]
}

variable "base_node_pool_machine_type" {
  type        = string
  default     = "c1.2"
  description = "List with instance types that are used in the base node group"
}

variable "base_node_pool_os_name" {
  type        = string
  default     = "flatcar"
  description = "The name of the OS image."
}

variable "base_node_pool_min_size" {
  type        = number
  default     = 2
  description = "Min instance count of the base node group"
}

variable "base_node_pool_max_size" {
  type        = number
  default     = 3
  description = "Max instance count of the base node group"
}

variable "base_node_pool_max_surge" {
  type        = number
  default     = 2
  description = "Maximum number of additional VMs that are created during an update. If set (larger than 0), then it must be at least the amount of zones configured for the nodepool. The `max_surge` and `max_unavailable` fields cannot both be unset at the same time."
}

variable "base_node_pool_max_unavailable" {
  type        = number
  default     = 0
  description = "Maximum number of VMs that that can be unavailable during an update. If set (larger than 0), then it must be at least the amount of zones configured for the nodepool. The `max_surge` and `max_unavailable` fields cannot both be unset at the same time."
}

variable "base_node_pool_volume_size" {
  type        = number
  default     = 20
  description = "The volume size in GB."
}

variable "base_node_pool_volume_type" {
  type        = string
  default     = "storage_premium_perf1"
  description = " Specifies the volume type."
}

variable "base_node_pool_labels" {
  type = any
  default = {
    base_nodepool = "base"
  }
  description = "Labels of the base node group"
}

variable "ske_managed_node_pools" {
  description = "SKE managed nodepools in addition to the base nodepool"
  type        = any
  default     = {}
}
variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.31"
}

variable "maintenance_enable_kubernetes_version_updates" {
  type        = bool
  default     = true
  description = "Flag to enable/disable auto-updates of the Kubernetes version. SKE automatically updates the cluster Kubernetes version if you have set `maintenance.enable_kubernetes_version_updates` to true or if there is a mandatory update."
}

variable "maintenance_enable_machine_image_version_updates" {
  type        = bool
  default     = true
  description = "Flag to enable/disable auto-updates of the OS image version."
}

variable "maintenance_start" {
  type        = string
  default     = "01:00:00Z"
  description = "Time for maintenance window start."
}

variable "maintenance_end" {
  type        = string
  default     = "02:00:00Z"
  description = "Time for maintenance window end."
}

variable "extensions_dns_enabled" {
  type        = bool
  default     = true
  description = "Flag to enable/disable DNS extensions. If set to `true`, SKE will then use an integrated version of externalDNS."
}

variable "extensions_dns_zones" {
  type        = list(string)
  default     = ["my-project.runs.onstackit.cloud"]
  description = "Specify a list of domain filters for externalDNS."
}
