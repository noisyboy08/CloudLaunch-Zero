variable "app_name" { type = string }
variable "environment" { type = string }
variable "alert_email" { type = string }
variable "lambda_function_name" {
  type    = string
  default = null
}
variable "ecs_cluster_name" {
  type    = string
  default = null
}
variable "ecs_service_name" {
  type    = string
  default = null
}
variable "load_balancer_arn_sfx" {
  type    = string
  default = null
}
variable "target_group_arn_sfx" {
  type    = string
  default = null
}
variable "tags" {
  type    = map(string)
  default = {}
}
