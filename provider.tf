###---root/provider.tf---

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16" 
    }
  }
}

provider "aws" {
  # profile = "default"
  region  = var.region
}