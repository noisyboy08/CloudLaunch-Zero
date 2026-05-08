variable "app_name" { type = string }
variable "environment" { type = string }
variable "alert_email" { type = string }
variable "monthly_limit_usd" {
  type    = number
  default = 200
}
variable "tags" {
  type    = map(string)
  default = {}
}
