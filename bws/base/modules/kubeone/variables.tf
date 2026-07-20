variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}

variable "kube_api_external_ip" {
  description = "External IP of Kube API"
  type        = string
}

variable "kube_api_external_port" {
  description = "External port of Kube API"
  type        = number
}

variable "os_auth_url" {
  description = "Openstack keystone url"
  type        = string
}

variable "os_application_credential_id" {
  description = "Openstack application credentials ID"
  type        = string
}

variable "os_application_credential_secret" {
  description = "Openstack application credentials secret"
  type        = string
}

variable "os_region_name" {
  description = "Openstack region name"
  type        = string
  default     = ""
}

variable "public_network_id" {
  description = "ID of the public network"
  type        = string
}

variable "private_network_name" {
  description = "Name of the private network"
  type        = string
}

variable "private_network_subnet_id" {
  description = "ID of the private subnet"
  type        = string
}

variable "private_network_subnet_name" {
  description = "Name of the private subnet"
  type        = string
}

variable "security_groups" {
  description = "List of security groups"
  type        = list(any)
}

variable "kubernetes_version" {
  description = "Kubernetes version to install"
  type        = string
}

variable "controlplane_instances" {
  description = "Controlplane instances"
  type        = list(any)
}

variable "worker_instances" {
  description = "Static worker instances"
  type        = list(any)
}

variable "worker_instance_flavor" {
  description = "Instance flavor for workers"
  type        = string
}

variable "worker_volume_size" {
  description = "Volume size for workers in GB"
  type        = number
}

variable "image_name" {
  description = "Name of the image for the machines"
  type        = string
}

variable "cinder_csi_plugin_volume_type" {
  description = "Cinder csi plugin add-on configuration values"
  type        = string
}

variable "availability_zone" {
  description = "Name of the availability zone"
  type        = string
}

variable "min_dynamic_workers" {
  description = "Minimum number of dynamic workers"
  type        = number
}

variable "max_dynamic_workers" {
  description = "Maximum number of dynamic workers"
  type        = number
}
