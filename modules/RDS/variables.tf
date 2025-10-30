variable "name" {
  description = "Identity name for RDS (will be used for identifier/tags)"
  type        = string
}

variable "engine" {
  description = "mysql | postgree"
  type        = string

  validation {
    condition     = contains(["mysql", "postgree"], var.engine)
    error_message = "Engine must be 'mysql' or 'postgree'"
  }
}

variable "engine_version" {
  description = "Engine version, example: '8.0.35' (mysql) hoặc '16.3' postgree"
  type        = string
}

variable "instance_class" {
  description = "instances type Ex: db.t3.micro"
  type        = string
}

variable "allocated_storage" {
  description = "Init GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Max allocated GB for autoscaling storage (0 = turn off)"
  type        = number
  default     = 0
}

variable "multi_az" {
  description = "Turn on Multi-az"
  type        = bool
  default     = false
}

variable "parameter_group_family" {
  description = "Family của parameter group (để null sẽ đoán theo engine/version thông dụng)"
  type        = string
  default     = null
}

variable "port" {
  description = "Port database (3306 mysql, 5432 postgres)"
  type        = number
  default     = 0
}

variable "username" {
  description = ""
  type        = string
  default     = "dbadmin"
}

variable "password" {
  description = "Create Admin (set null will be random.)"
  type        = string
  sensitive   = true
  default     = null
}

variable "publicly_accessible" {
  description = "Whether the database is publicly accessible"
  type        = bool
  default     = false
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs (>= 2 Nếu MultiAZ)"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC contains RDS"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed access to DB"
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed access to DB"
  type        = list(string)
  default     = []
}

variable "parameters" {
  description = "Lisf of parameters for parameter group"
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "pending-reboot")
  }))
  default = []
}

variable "create_secret" {
  description = "Create a Secrets Manager secret for RDS credentials"
  type        = bool
  default     = false
}

variable "storage_type" {
  description = "Storage type: standard | gp2 | gp3 | io1 | io2"
  type        = string
  default     = "gp3"
}

variable "storage_encrypted" {
  description = "Enable encryption at rest"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for encryption (null = AWS manageds)"
  type        = string
  default     = null
}

variable "backup_retention_days" {
  description = "Backup retention period in days (0 = disable)"
  type        = number
  default     = 7
}

variable "apply_immediately" {
  description = "Apply changes immediately"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "skip final snapshot on deletion"
  type        = bool
  default     = false
}

variable "final_snapshot_identifier_prefix" {
  description = "Prefix for the final snapshot identifier"
  type        = string
  default     = "final"
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = false
}

variable "performance_insights_retention_period" {
  description = "Retention period for Performance Insights data"
  type        = number
  default     = null
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default = {
    Iac = "Terraform"
  }
}



