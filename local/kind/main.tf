terraform {
  required_version = "~> 1.3.5"

  backend "local" {
    # path = "terraform.tfstate"
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 4.5.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.18.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.9.0"
    }
    kind = {
      source  = "tehcyx/kind"
      version = "0.0.16"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = ">= 0.19.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
  }
}
