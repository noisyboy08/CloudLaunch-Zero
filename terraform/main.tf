provider "aws" {
  region = var.region

  default_tags {
    tags = merge(var.tags, {
      Project     = var.app_name
      Environment = var.environment
      ManagedBy   = "terraform"
    })
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

module "vpc" {
  source             = "./modules/vpc"
  app_name           = var.app_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  az_count           = var.az_count
  enable_nat_gateway = var.enable_nat_gateway
  tags               = var.tags
}

module "security" {
  source          = "./modules/security"
  app_name        = var.app_name
  environment     = var.environment
  region          = var.region
  vpc_id          = module.vpc.vpc_id
  cloudtrail_name = "${var.app_name}-${var.environment}-trail"
  tags            = var.tags
}

module "storage" {
  source      = "./modules/storage"
  app_name    = var.app_name
  environment = var.environment
  tags        = var.tags
}

module "app_serverless" {
  count = var.enable_serverless ? 1 : 0

  source              = "./modules/app-serverless"
  app_name            = var.app_name
  environment         = var.environment
  region              = var.region
  api_token           = var.api_token
  private_subnet_ids  = module.vpc.private_subnet_ids
  lambda_security_ids = [module.security.serverless_security_group_id]
  tags                = var.tags
}

module "app_containers" {
  count = var.enable_containers ? 1 : 0

  source             = "./modules/app-containers"
  app_name           = var.app_name
  environment        = var.environment
  region             = var.region
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  ecs_security_ids   = [module.security.ecs_security_group_id]
  alb_security_ids   = [module.security.alb_security_group_id]
  db_security_ids    = [module.security.rds_security_group_id]
  db_username        = var.db_username
  db_password        = var.db_password
  container_image    = var.container_image
  tags               = var.tags
}

module "observability" {
  source                = "./modules/observability"
  app_name              = var.app_name
  environment           = var.environment
  alert_email           = var.alert_email
  lambda_function_name  = var.enable_serverless ? module.app_serverless[0].lambda_function_name : null
  ecs_cluster_name      = var.enable_containers ? module.app_containers[0].ecs_cluster_name : null
  ecs_service_name      = var.enable_containers ? module.app_containers[0].ecs_service_name : null
  load_balancer_arn_sfx = var.enable_containers ? module.app_containers[0].load_balancer_arn_suffix : null
  target_group_arn_sfx  = var.enable_containers ? module.app_containers[0].target_group_arn_suffix : null
  tags                  = var.tags
}

module "cost" {
  source            = "./modules/cost"
  app_name          = var.app_name
  environment       = var.environment
  alert_email       = var.alert_email
  monthly_limit_usd = var.environment == "production" ? 500 : 150
  tags              = var.tags
}
