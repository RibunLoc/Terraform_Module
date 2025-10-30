variable "region" {
  description = "Region deploy IAC"
  type        = string
  default     = "us-east-1"
}

variable "aws_s3_buckets" {
  type        = list(string)
  description = "List of name s3 buckets"
}