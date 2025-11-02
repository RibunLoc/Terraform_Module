variable "name" {
  description = "Name ALB you will create"
  type        = string
  default     = "ALB-Terraform-Default"
}

variable "vpc_id" {
  description = "VPC placed ALB"
  type        = string
}

variable "target_type" {
  description = "Target type EC2"
  type        = string
  default     = "instance"
}

variable "enable_https" {
  description = "Turn on using HTTPS Protocols"
  type        = bool
  default     = false
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "health_check_path" {
  description = "The path to the health check endpoint"
  type        = string
}

variable "https_certificate_arn" {
  description = "The ARN of the SSL certificate for HTTPS"
  type        = string
  default     = null
}

variable "target_instance_ids" {
  description = ""
  type        = list(string)
  default     = []
}

variable "tags" {
  type = map(string)
  default = {
    "Iac"         = "Terraform"
    "Environment" = "Dev"
  }
}