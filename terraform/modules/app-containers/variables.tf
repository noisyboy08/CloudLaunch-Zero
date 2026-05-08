variable "app_name" { type = string }
variable "environment" { type = string }
variable "region" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }
variable "ecs_security_ids" { type = list(string) }
variable "alb_security_ids" { type = list(string) }
variable "db_security_ids" { type = list(string) }
variable "container_image" { type = string }
variable "db_username" { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}
variable "tags" {
  type    = map(string)
  default = {}
}
