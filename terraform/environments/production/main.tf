terraform {
  backend "s3" {
    bucket         = "cloudlaunch-zero-tfstate-us-east-1"
    key            = "production/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "cloudlaunch-zero-tflock"
    encrypt        = true
  }
}

module "stack" {
  source = "../../"

  app_name           = "cloudlaunch-zero"
  environment        = "production"
  region             = "us-east-1"
  enable_serverless  = true
  enable_containers  = true
  enable_nat_gateway = true

  db_password = var.db_password
  api_token   = var.api_token
  alert_email = var.alert_email

  tags = {
    Owner       = "platform"
    CostCenter  = "engineering"
    Environment = "production"
    Compliance  = "high"
  }
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "api_token" {
  type      = string
  sensitive = true
}

variable "alert_email" {
  type = string
}
