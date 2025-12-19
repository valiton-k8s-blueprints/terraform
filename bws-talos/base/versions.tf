terraform {
  required_version = ">= 1.0"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "3.0.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.9.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.10.1"
    }
  }
}
