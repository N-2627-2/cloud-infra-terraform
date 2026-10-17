terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote backend configuration template
  # Uncomment once remote S3 state bucket and DynamoDB lock table are created
  # backend "s3" {
  #   bucket         = "securechain-tfstate-bucket"
  #   key            = "dev/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "securechain-tfstate-locks"
  #   encrypt        = true
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