terraform {
  required_version = "~> 1.9.5"

  backend "local" {
    # path = "terraform.tfstate"
  }

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

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
