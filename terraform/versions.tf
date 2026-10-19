terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.4"
    }
  }

  # Optional: uncomment to keep state in S3 instead of on your laptop.
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "ecs-notes/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = var.project
      ManagedBy = "terraform"
    }
  }
}

# Reads VAULT_ADDR and VAULT_TOKEN from your environment.
provider "vault" {}
