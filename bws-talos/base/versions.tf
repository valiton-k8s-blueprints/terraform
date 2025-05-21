terraform {
  required_version = ">= 1.0"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.7.1"
    }
  }
}
