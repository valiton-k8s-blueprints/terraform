terraform {
  required_version = ">= 1"
  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = "~> 0.55.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.36.0"
    }
  }
}
