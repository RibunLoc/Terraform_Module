variable "name" {
  description = "Name logic for ASG/LT"
  type        = string
}

variable "vpc_id" {
  description = "Name of VPC for security group"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet for ASG"
  type        = list(string)
}

variable "security_group_ids" {
  description = "SG apply for primary ENI"
  type        = list(string)
  default     = []
}

variable "additional_ingress_rules" {
  description = "Ingress security group ASG"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = []
}

variable "ami_id" {
  description = "AMI ID for lanch template"
  type        = string
}

variable "instance_type" {
  description = "Configure for vCPU, Mem"
  type        = string
  default     = "t2.micro"
}

variable "block_device_mappings" {
  description = "Configuration EBS Volumes"
  type = list(object(
    {
      device_name           = string
      volume_size           = number                  // GiB
      volume_type           = optional(string, "gp3") // gp2, gp3, 
      delete_on_termination = optional(bool, true)    // if delete ec2 instance, volume that attach to instance will be deleted
      encrypted             = optional(bool, false)
      iops                  = optional(number)
      throughput            = optional(number)
    }
  ))
  default = []
}

variable "iam_instance_profile" {
  description = "Name IAM instance profile"
  type        = string
  default     = null
}

variable "key_name" {
  description = "SSH Key to access"
  type        = string
  default     = null
}

variable "user_data_vars" {
  description = "Variables injected templatefile user_data"
  type        = map(string)
  default     = {}
}

variable "desired_capacity" {
  type = number
}
variable "min_size" {
  type = number
}
variable "max_size" {
  type = number
}

variable "target_group_arns" {
  description = "Mount ALB/NLB target groups"
  type        = list(string)
  default     = []
}

variable "health_check_type" {
  description = "Health check type for ASG"
  type        = string
  default     = "EC2"
}

variable "enable_instance_refresh" {
  description = "Enable instance refresh when ASG configuration change"
  type        = bool
  default     = true
}

variable "mixed_instances" {
  description = "Turn on Mixed Instances Policy (Spot + On-Demand)"
  type = object({
    enabled              = bool
    on_demand_base       = optional(number)
    on_demand_percentage = optional(number)
    spot_max_price       = optional(string)
    override_types       = optional(list(string))
  })
  default = {
    enabled = false
  }
}

variable "cpu_target_percent" {
  description = "Target tracking CPU % (default = not created)"
  type        = number
  default     = null
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default = {
    "env" = "dev"
    "Iac" = "terraform"
  }
}

