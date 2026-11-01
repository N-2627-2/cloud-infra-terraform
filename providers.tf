terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote backend configuration template
  # Uncomment and configure backend.hcl once S3 state bucket is migrated
  # backend "s3" {
  #   bucket       = "securechain-tfstate-dev-2627"
  #   key          = "dev/terraform.tfstate"
  #   region       = "us-east-1"
  #   use_lockfile = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "SecureChain"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}