variable "name" { type = string }
variable "vpc_id" { type = string }
variable "ami_id" { type = string }
variable "subnet_id" { type = string }
variable "key_name" { type = string }

variable "ingress_cidr_blocks" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "tags" {
  type = map(string)
  default = {
    "env" = "dev"
    "Iac" = "terraform"
  }
}

variable "associate_public_ip" {
  type        = bool
  default     = false
  description = "Placing at Public subnet"
}

variable "user_data" {
  type    = string
  default = ""
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "instance_profile" {
  type        = string
  default     = null
  description = "IAM Instance Profile to attach to EC2 instance"
}

variable "root_volume_size" {
  type    = string
  default = "8"
}

variable "additional_ingress_rules" {
  description = "List of rules Ingress custom"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "iam_policy_arns" {
  description = "List of IAM policy ARNs to attach to the EC2 instance role"
  default     = []
  type        = list(string)
}










