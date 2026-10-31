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

module "ecs" {
  source = "../../modules/ecs"

  environment              = "dev"
  vpc_id                   = module.vpc.vpc_id
  private_app_subnet_ids   = module.vpc.private_app_subnet_ids
  app_security_group_id    = module.security.app_security_group_id
  ecs_execution_role_arn   = module.security.ecs_execution_role_arn
  ecs_task_role_arn        = module.security.ecs_task_role_arn
  portal_target_group_arn  = module.alb.portal_target_group_arn
  backend_target_group_arn = module.alb.backend_target_group_arn
  db_secret_arn            = module.rds.db_secret_arn
}

module "vpn" {
  source = "../../modules/vpn"

  environment                      = "dev"
  aws_region                       = var.aws_region
  vpc_id                           = module.vpc.vpc_id
  public_subnet_id                 = module.vpc.public_subnet_ids[0]
  private_route_table_id           = module.vpc.private_route_table_id
  allowed_lab_cidr                 = var.vpn_allowed_lab_cidr
  peer_public_ip_cidr              = var.vpn_peer_public_ip_cidr
  wireguard_peer_public_key        = var.vpn_peer_public_key
  wireguard_peer_tunnel_cidr       = var.vpn_peer_tunnel_cidr
  wireguard_private_key_secret_arn = var.vpn_private_key_secret_arn
}

module "rds" {
  source = "../../modules/rds"

  environment          = "dev"
  vpc_id               = module.vpc.vpc_id
  db_subnet_group_name = module.vpc.db_subnet_group_name
  db_security_group_id = module.security.db_security_group_id
  db_name              = "securechain"
  db_username          = var.db_username
}

module "alb" {
  source = "../../modules/alb"

  environment           = "dev"
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
}