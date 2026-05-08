resource "aws_s3_bucket" "artifacts" {
  bucket        = "${var.app_name}-${var.environment}-artifacts"
  force_destroy = false

  tags = merge(var.tags, {
    Name = "${var.app_name}-${var.environment}-artifacts"
    Data = "artifacts"
  })
}

resource "aws_s3_bucket" "logs" {
  bucket        = "${var.app_name}-${var.environment}-logs"
  force_destroy = false

  tags = merge(var.tags, {
    Name = "${var.app_name}-${var.environment}-logs"
    Data = "logs"
  })
}
