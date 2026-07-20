terraform {
  required_version = ">= 1.0"

  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.7.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.10.1, < 3.0.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.5.0"
    }
  }
}
