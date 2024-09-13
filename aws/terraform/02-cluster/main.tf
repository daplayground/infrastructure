terraform {
  required_version = "1.9.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.42.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.2.3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.32.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.15.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "terraform_remote_state" "bootstrap" {
  backend = "local"

  config = {
    path = "../01-bootstrap/terraform.tfstate"
  }
}
