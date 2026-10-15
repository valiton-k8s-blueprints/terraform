terraform {
  required_version = ">= 1.0"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.7.2"
    }
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">=3.0.0"
    }
  }
}
