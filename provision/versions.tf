# Enforce minimum Terraform and provider version numbers.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.30.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.2.1"
    }
  }

  required_version = ">= 1.1.4"
}
