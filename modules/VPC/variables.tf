variable "name" {
  description = "Name of VPC (prefix cho resource)"
  type        = string
  default     = "VPC-Terraform-Default"
}

variable "cidr_block" {
  description = "CIDR BLOCK of VPC"
  type        = string
  default     = "10.0.0.0/16"
}


variable "enable_nat_gateway" {
  description = "Do you enable nat gateway?"
  type        = bool
  default     = false
}

variable "az_count" {
  description = "The number of Availability Zones to create Subnets."
  type        = number
  default     = 2
}

variable "tags" {
  description = "Tags chung"
  type        = map(string)
  default = {
    "env" = "dev"
  }
}

variable "enable_ssm_endpoints" {
  description = "Turn on, creating VPC Endpoints for SSM (ssm, ssmmessages, ec2messages)."
  type        = bool
  default     = false
}

variable "ssm_endpoints_subnet_ids" {
  description = "List of subnet IDs to place ENI of Interface endpoints"
  type        = list(string)
  default     = []
}

variable "endpoint_security_group_additional_ingress_cidrs" {
  description = "Additional CIDR blocks to allow inbound access to VPC Interface Endpoints security group."
  type        = list(string)
  default     = []
}

# Optional create s3 gateway endpoint  for access internal s3
variable "enable_s3_gateway_endpoint" {
  description = "Turn on creating Gateway Endpoints for S3 bucket"
  type        = bool
  default     = false
}

variable "private_route_table_ids" {
  description = "(Using for S3 bucket) Route table IDs of private subnets to attach endpoint"
  type        = list(string)
  default     = []
}

