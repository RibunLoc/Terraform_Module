variable "create_log_group" {
  description = "Nếu TRUE, tạo aws_cloudwatch_log_group. Nếu FALSE, bỏ qua."
  type        = bool
  default     = false
}

variable "create_metric_alarm" {
  description = "Nếu TRUE, tạo aws_cloudwatch_metric_alarm. Nếu FALSE, bỏ qua."
  type        = bool
  default     = false
}

variable "log_group_name" {
  description = "Name of CloudWatch Log Group"
  type        = string
  default     = null
}

variable "retention_in_days" {
  description = "Time save log (persecond). Set 0 if you want to set up unlimited retention."
  type        = number
  default     = 30
}

# --- Metrics Alarms configurations ----
variable "alarm_name" {
  description = "Name of Metrics Alarm"
  type        = string
  default     = "Terraform Alarm Name Default."
}

variable "metric_name" {
  description = "Name of Metrics to observibility (Ex: CPUUtilization, Invocations.)"
  type        = string
  default     = null
}

variable "instance_id" {
  description = "ID of the EC2 instance to monitor"
  type        = map(string)
  default     = {}
}

variable "namespace" {
  description = "Namespace of the metrics (Ex: AWS/EC2, AWS/Lambda.)"
  type        = string
  default     = "AWS/EC2"
}

variable "threshold" {
  description = "Threshold (value) to active Alarm"
  type        = number
  default     = null
}

variable "comparision_operator" {
  description = "Comparision Operator(Ex: GreaterThanOrEqualToThreshold)"
  type        = string
  default     = "GreaterThanOrEqualToThreshold"
}

variable "period" {
  description = "The number of time (second) evaluate Metrics."
  type        = number
  default     = 300
}

variable "sns_topic_arn" {
  description = "ARN of the SNS Topic to send notifications when the alarm is activated."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
