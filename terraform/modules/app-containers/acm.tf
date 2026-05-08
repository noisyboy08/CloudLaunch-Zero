resource "aws_acm_certificate" "app" {
  domain_name       = "${var.environment}.${var.app_name}.example.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}
