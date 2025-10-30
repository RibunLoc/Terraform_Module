variable "role_name" {
  description = "Name of IAM Role and Instance Profile"
  type        = string
}

variable "assume_role_policy" {
  description = "Trust Policy allow EC2 assume this role"
  type        = string
}

variable "policy_arns" {
  description = "List of ARN of the managed policies need to attach Role Ex: 'arn:aws:iam:policy/AmazonSSMManagedInstanceCore"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to assign to the IAM Role"
  type        = map(string)
  default = {
    IaC = "Terraform"
  }
}
