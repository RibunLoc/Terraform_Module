variable "bucket_name" {
  description = "Name bucket s3 will be created"
  type        = string
}

variable "acl" {
  description = "Access control list for the bucket (private, public-read, etc.)"
  type        = string
  default     = "private"
}

variable "block_public_acls" {
  description = "Preventing ACL public applied bucket."
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Prevent the public policy bucket"
  type        = bool
  default     = false
}

variable "ignore_public_acls" {
  description = "Ignore public ACL applied for bucket"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Applying restricts if the bucket has public policy"
  type        = bool
  default     = false
}
variable "enable_versioning" {
  description = "Turn on Versioning feature for the bucket"
  type        = bool
  default     = false
}

variable "lifecycle_rules" {
  description = "List of managed lifecycle rule for S3 bucket."
  type = list(object({
    id                       = string
    enabled                  = bool
    filter_prefix            = optional(string)
    transition_days          = optional(number) // Số ngày sau khi đối tượng được tạo để chuyển đổi lớp lưu trữ
    transition_storage_class = optional(string) // Ex: GLACIER

    expiration_days                    = optional(number) // Số ngày sau khi đối tượng được tạo để hết hạn
    noncurrent_version_expiration_days = optional(number) // Số ngày sau khi phiên bản không hiện tại được tạo để hết hạn
  }))
  default = []
}

// define variables for CORS
variable "cors_rule" {
  description = "List of rule CORS for bucket s3."
  type = list(object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = optional(list(string))
    max_age_seconds = optional(number)
  }))
  default = []
}

variable "tags" {
  type = map(string)
  default = {
    "IaC" = "Terraform"
  }
}



