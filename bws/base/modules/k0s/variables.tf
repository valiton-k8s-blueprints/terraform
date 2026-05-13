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

variable "k0s_version" {
  description = "k0s version to install"
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

variable "openstack_helm_chart_version" {
  description = "Version of the openstack helm chart"
  type        = string
}

variable "openstack_ccm_secret" {
  description = "Secret YAML for Openstack CCM"
  type        = string
}

variable "k8s_keystone_ca" {
  description = "CA for k8s-keystone"
  type        = string
}

variable "k8s_keystone_auth_manifests" {
  description = "Manifests for k8s-keystone"
}

variable "k8s_keystone_auth_config" {
  description = "Webhook config for k8s-keystone"
  type        = string
}

variable "os_token" {
  description = "Openstack authentication token"
  type        = string
}

variable "bastion_public_ip" {
  description = "Public IP address of bastion host"
  type        = string
}
