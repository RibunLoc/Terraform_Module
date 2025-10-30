output "db_identifier" {
  value = aws_db_instance.this.id
}

output "endpoint" {
  value = aws_db_instance.this.endpoint
}

output "port" {
  value = aws_db_instance.this.port
}

output "security_group_ids" {
  value = aws_db_instance.this.vpc_security_group_ids
}

output "subnet_group" {
  value = aws_db_subnet_group.this.name
}

output "parameter_group" {
  value = length(aws_db_parameter_group.this) > 0 ? aws_db_parameter_group.this[0].name : null
}

output "secret_arn" {
  value       = try(aws_secretsmanager_secret.this[0].arn, null)
  description = "ARN of Secret Manager (if create_secret = true)"
  sensitive   = true
}

