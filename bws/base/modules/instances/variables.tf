variable "name_prefix" {
  description = "Prefix to add to names of created resources"
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

variable "image_name" {
  description = "Name of the image for the machines"
  type        = string
}

variable "worker_instance_flavor" {
  description = "Instance flavor for workers"
  type        = string
}
variable "worker_volume_type" {
  description = "Volume type for workers"
  type        = string
}

variable "worker_volume_size" {
  description = "Volume size for workers in GB"
  type        = number
}

variable "worker_port_id" {
  description = "Worker port ids list"
  type        = list(string)
}

variable "worker_user_data" {
  description = "User data for worker"
  type        = string
}

variable "controlplane_instance_flavor" {
  description = "Instance flavor for controlplane"
  type        = string
}

variable "controlplane_volume_type" {
  description = "Volume type for controlplan"
  type        = string
}

variable "controlplane_volume_size" {
  description = "Volume size for controlplane in GB"
  type        = number
}

variable "controlplane_port_id" {
  description = "Controlplane port ids list"
  type        = list(string)
}

variable "controlplane_user_data" {
  description = "User data for controlpane"
  type        = string
}
