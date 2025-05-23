variable "kube_prometheus_stack" {
  description = "Kube prometheus stack config"
  type        = any
  default     = {}
}

variable "cinder_csi_plugin" {
  description = "Cinder csi plugin config"
  type        = any
  default     = {}
}

variable "addons" {
  description = "Kubernetes addons"
  type        = any
}
