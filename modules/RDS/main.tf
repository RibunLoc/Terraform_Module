locals {
  major = try(split(".", var.engine_version)[0], var.engine_version)

  inferred_family = var.engine == "mysql" ? (startswith(var.engine_version, "8.0") ? "mysql8.0"
  : (startswith(var.engine_version, "5.7") ? "mysql5.7" : null)) : (var.engine == "postgres" ? "postgres${local.major}" : null)

  family    = coalesce(var.parameter_group_family, local.inferred_family)
  db_port   = var.port != 0 ? var.port : (var.engine == "mysql" ? 3306 : 5432)
  name_sane = replace(lower(var.name), "/[^a-z0-9-]/", "-")
}

resource "random_password" "this" {
  length           = 20
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>?@"
  count            = var.password == null ? 1 : 0
}

resource "aws_db_subnet_group" "this" {
  name       = "${local.name_sane}-dbsubnet"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, {
    Name = "${local.name_sane}-dbsubnet"
  })
}

resource "aws_security_group" "this" {
  name        = "${local.name_sane}-rds-sg"
  description = "Ingress only from allowed CIDRs/SGs"
  vpc_id      = var.vpc_id
  tags = merge(var.tags, {
    Name = "${local.name_sane}-rds-sg"
  })
}

resource "aws_security_group_rule" "ingress_cidrs" {
  count             = length(var.allowed_cidr_blocks)
  type              = "ingress"
  from_port         = local.db_port
  to_port           = local.db_port
  protocol          = "tcp"
  cidr_blocks       = [var.allowed_cidr_blocks[count.index]]
  security_group_id = aws_security_group.this.id

  description = "DB access from CIDR - ${var.allowed_cidr_blocks[count.index]}"
}

resource "aws_security_group_rule" "ingress_sgs" {
  count                    = length(var.allowed_security_group_ids)
  type                     = "ingress"
  from_port                = local.db_port
  to_port                  = local.db_port
  protocol                 = "tcp"
  source_security_group_id = var.allowed_security_group_ids[count.index]
  security_group_id        = aws_security_group.this.id
}

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.this.id
}

# 
resource "aws_db_parameter_group" "this" {
  count  = local.family == null ? 0 : 1
  name   = "${local.name_sane}-param"
  family = local.family
  tags   = merge(var.tags, { Name = "${local.name_sane}-param" })

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }
}

locals {
  admin_password_final = var.password != null ? var.password : random_password.this[0].result
}

# Secrets Manager (optional)
resource "aws_secretsmanager_secret" "this" {
  count       = var.create_secret ? 1 : 0
  name        = "${local.name_sane}-rds-credentials"
  description = "RDS credentials for ${var.name} (${var.engine})"
  tags        = var.tags
}

resource "aws_secretsmanager_secret_version" "this" {
  count     = var.create_secret ? 1 : 0
  secret_id = aws_secretsmanager_secret.this[0].id
  secret_string = jsonencode({
    username = var.username,
    password = local.admin_password_final
    engine   = var.engine,
    port     = local.db_port
  })
}

resource "aws_db_instance" "this" {

  identifier     = local.name_sane
  engine         = var.engine         // mysql
  engine_version = var.engine_version // 8.0.42
  instance_class = var.instance_class // db.t4g.micro

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  publicly_accessible    = var.publicly_accessible // not access internet
  port                   = local.db_port

  username = var.username
  password = local.admin_password_final

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = var.kms_key_id

  multi_az                = var.multi_az
  backup_retention_period = var.backup_retention_days
  copy_tags_to_snapshot   = true

  apply_immediately         = var.apply_immediately
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.final_snapshot_identifier_prefix}-${replace(timestamp(), ":", "")}"

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period
  performance_insights_kms_key_id       = var.kms_key_id

  parameter_group_name = length(aws_db_parameter_group.this) > 0 ? aws_db_parameter_group.this[0].name : null

  tags = merge(var.tags, {
    Name = "${local.name_sane}"
  })
}
