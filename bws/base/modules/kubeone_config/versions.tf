terraform {
  required_version = ">= 1.0"

  required_providers {
    ct = {
      source  = "poseidon/ct"
      version = "0.14.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.7.0"
    }
  }
}
