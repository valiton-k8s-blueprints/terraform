terraform {
  required_version = ">= 1"
  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = "~> 0.57.0"
    }
  }
}
