variable "environment" {
  default     = "development"
  type        = string
  description = "Infrastructure environment name (e.g. development, staging, production)."
}
variable "base_name" {
  description = "Name of your base infrastructure."
  type        = string
  default     = "my-project"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.base_name))
    error_message = "The base_name must only contain lowercase letters, numbers, and dashes."
  }
}
variable "vpc_cidr" {
  description = "VPC CIDR, if empty a random CIDR will be chosen"
  type        = string
  default     = ""
}
variable "azs_count" {
  description = "Number of availability zones"
  type        = number
  default     = 2
}
variable "single_nat_gateway" {
  description = "True if only a single NAT gateway should be deployed instead of one per AZ"
  type        = bool
  default     = false
}
variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "base_node_group_instance_types" {
  type        = list(string)
  default     = ["t4g.medium"]
  description = "List with instance types that are used in the base node group"
}

variable "base_node_group_ami_type" {
  type        = string
  default     = "AL2023_ARM_64_STANDARD"
  description = "AMI type used by the base node group"
}

variable "base_node_group_capacity_type" {
  type        = string
  default     = "ON_DEMAND"
  description = "Capacity types used by the base node group"
}

variable "base_node_group_min_size" {
  type        = number
  default     = 1
  description = "Min instance count of the base node group"
}

variable "base_node_group_max_size" {
  type        = number
  default     = 3
  description = "Max instance count of the base node group"
}

variable "base_node_group_desired_size" {
  type        = number
  default     = 2
  description = "Initial desired instance count of the base node group"
}

variable "base_node_group_labels" {
  type = any
  default = {
    base_nodepool = "base"
  }
  description = "Labels of the base node group"
}

variable "eks_managed_node_groups" {
  description = "EKS managed nodegroups in addition to the base nodegroup"
  type        = any
  default     = {}
}
variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.32"
}

variable "cluster_enabled_log_types" {
  description = "List of the desired control plane logs to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type        = list(any)
  default     = []
}

variable "create_cloudwatch_log_group" {
  description = "Determines whether a log group is created by this module for the cluster logs. If not, AWS will automatically create one if logging is enabled"
  type        = bool
  default     = false
}

variable "cloudwatch_log_group_retention_in_days" {
  default     = 30
  type        = number
  description = "Number of days to retain log events."
}

variable "cloudwatch_log_group_class" {
  default     = null
  type        = string
  description = "Specified the log class of the log group. Possible values are: `STANDARD` or `INFREQUENT_ACCESS`"
}

