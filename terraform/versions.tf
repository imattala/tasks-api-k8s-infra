terraform {
  required_version = ">= 1.9"

  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "0.11.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.3.0"
    }
  }
}
