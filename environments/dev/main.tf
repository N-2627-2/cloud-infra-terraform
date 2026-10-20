module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr                 = "10.10.0.0/16"
  public_subnet_cidrs      = ["10.10.1.0/24", "10.10.2.0/24"]
  private_app_subnet_cidrs = ["10.10.10.0/24", "10.10.11.0/24"]
  private_db_subnet_cidrs  = ["10.10.20.0/24", "10.10.21.0/24"]
  availability_zones       = ["us-east-1a", "us-east-1b"]
  environment              = "dev"
}

module "security" {
  source = "../../modules/security"

  vpc_id      = module.vpc.vpc_id
  environment = "dev"
}