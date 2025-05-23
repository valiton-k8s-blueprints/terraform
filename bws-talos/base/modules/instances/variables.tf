variable "name_prefix" {
  description = "Prefix to add to names of created resources"
  default     = "cluster"
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

variable "image_name" {
  description = "Name of the image for the machines"
  default     = "talos"
}

variable "worker_instance_flavor" {
  description = "Instance flavor for workers"
  default     = "BWS-T1-2-4"
}
variable "worker_volume_type" {
  description = "Volume type for workers"
  default     = "ssd-10000-250"
}

variable "worker_volume_size" {
  description = "Volume size for workers"
  default     = "40"
}

variable "worker_port_id" {
  default = ["1", "2"]
}

variable "worker_user_data" {
  default = ""
}

variable "controlplane_instance_flavor" {
  default = "BWS-T1-2-4"
}

variable "controlplane_volume_type" {
  default = "ssd-10000-250"
}

variable "controlplane_volume_size" {
  default = "20"
}

variable "controlplane_port_id" {
  default = ["3", "4", "5"]
}
