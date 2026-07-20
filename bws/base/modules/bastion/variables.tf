variable "name_prefix" {
  description = "Prefix to add to names of created resources"
  type        = string
}

variable "image_name" {
  description = "Name of the image for the machine"
  type        = string
}

variable "instance_flavor" {
  description = "Instance flavor"
  type        = string
}

variable "volume_type" {
  description = "Volume type"
  type        = string
}

variable "volume_size" {
  description = "Volume size in GB"
  type        = number
}

variable "port_id" {
  description = "Port id"
  type        = string
}

variable "keypair_name" {
  description = "Name of existing SSH key pair"
  type        = string
}
