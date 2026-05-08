resource "aws_guardduty_detector" "this" {
  enable = true

  finding_publishing_frequency = "SIX_HOURS"

  tags = merge(var.tags, {
    Name = "${var.app_name}-${var.environment}-guardduty"
  })
}
