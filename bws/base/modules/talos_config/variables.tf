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

variable "kubernetes_version" {
  description = "Kubernetes version to install"
  type        = string
}

variable "talos_secrets" {
  description = "Object of secrets generated with talosctl gen secrets"
  type        = any
}

variable "pod_security_exemptions_namespaces" {
  description = "List of namespaces exempt from pod security configuration"
  type        = list(string)
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

variable "openstack_ccm_secret" {
  description = "Secret YAML for Openstack CCM"
  type        = string
}

variable "cluster_domain" {
  description = "Domain for the cluster internal DNS, usually cluster.local"
  type        = string
}
