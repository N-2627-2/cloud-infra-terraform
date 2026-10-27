terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "securechain-tfstate-dev-2627"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "securechain-tfstate-locks-dev"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "SecureChain"
      Environment = "dev"
      ManagedBy   = "Terraform"
    }
  }
}
