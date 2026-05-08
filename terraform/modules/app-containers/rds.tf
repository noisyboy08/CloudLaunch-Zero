resource "aws_db_subnet_group" "app" {
  name       = "${var.app_name}-${var.environment}-db-subnets"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.app_name}-${var.environment}-db-subnets"
  })
}

locals {
  is_production = var.environment == "production"
}

resource "aws_db_instance" "app" {
  identifier                            = "${var.app_name}-${var.environment}-db"
  engine                                = "postgres"
  engine_version                        = "16.3"
  instance_class                        = local.is_production ? "db.t4g.medium" : "db.t4g.micro"
  allocated_storage                     = local.is_production ? 50 : 20
  max_allocated_storage                 = local.is_production ? 500 : 100
  db_name                               = "appdb"
  username                              = var.db_username
  password                              = var.db_password
  db_subnet_group_name                  = aws_db_subnet_group.app.name
  vpc_security_group_ids                = var.db_security_ids
  storage_encrypted                     = true
  multi_az                              = local.is_production
  publicly_accessible                   = false
  backup_retention_period               = local.is_production ? 30 : 7
  deletion_protection                   = local.is_production
  iam_database_authentication_enabled   = true
  performance_insights_enabled          = true
  performance_insights_retention_period = local.is_production ? 731 : 7
  copy_tags_to_snapshot                 = true
  auto_minor_version_upgrade            = true
  skip_final_snapshot                   = !local.is_production
  final_snapshot_identifier             = local.is_production ? "${var.app_name}-${var.environment}-db-final-${formatdate("YYYYMMDDhhmmss", timestamp())}" : null

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  lifecycle {
    ignore_changes = [final_snapshot_identifier]
  }

  tags = var.tags
}
