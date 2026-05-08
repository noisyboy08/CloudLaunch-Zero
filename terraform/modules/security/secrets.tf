resource "aws_secretsmanager_secret" "app" {
  name                    = "${var.app_name}/${var.environment}/app-secrets"
  recovery_window_in_days = 7

  tags = merge(var.tags, {
    Name = "${var.app_name}-${var.environment}-app-secrets"
  })
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id = aws_secretsmanager_secret.app.id
  secret_string = jsonencode({
    DB_HOST    = "set-at-runtime"
    DB_PORT    = "5432"
    API_KEY    = "rotate-me"
    UPDATED_AT = timestamp()
  })
}
