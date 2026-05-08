variable "app_name" { type = string }
variable "environment" { type = string }
variable "region" { type = string }
variable "api_token" {
  type      = string
  sensitive = true
}
variable "private_subnet_ids" {
  type = list(string)
}
variable "lambda_security_ids" {
  type = list(string)
}
variable "tags" {
  type    = map(string)
  default = {}
}
