variable "ca_crt" {
  description = "CA certificate for the cluster"
  type        = string
}

variable "ca_key" {
  description = "CA key for the cluster"
  type        = string
}

variable "os" {
  description = "Type of OS"
  type = string
  validation {
    condition     = contains(["ubuntu", "flatcar"], var.os)
    error_message = "Valid values for os are ubuntu and flatcar."
  }
}
