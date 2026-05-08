variable "app_name" {
  description = "Application name prefix"
  type        = string
  default     = "cloudlaunch-zero"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.42.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones"
  type        = number
  default     = 2
}

variable "enable_nat_gateway" {
  description = "Create NAT gateways for private subnets"
  type        = bool
  default     = true
}

variable "enable_serverless" {
  description = "Enable serverless application pattern"
  type        = bool
  default     = true
}

variable "enable_containers" {
  description = "Enable containers application pattern"
  type        = bool
  default     = true
}

variable "container_image" {
  description = "Container image for ECS service"
  type        = string
  default     = "public.ecr.aws/nginx/nginx:stable"
}

variable "db_username" {
  description = "RDS database username"
  type        = string
  default     = "appuser"
}

variable "db_password" {
  description = "RDS database password"
  type        = string
  sensitive   = true
}

variable "api_token" {
  description = "Shared token used by Lambda authorizer"
  type        = string
  sensitive   = true
}

variable "alert_email" {
  description = "Email for alert notifications"
  type        = string
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
