output "log_group_name" {
  description = "Name of cloudwatch Log Group created"
  value       = aws_cloudwatch_log_group.this
}

output "metric_alarm_arn" {
  description = "ARN của Metric Alarm đã tạo."
  value = {
    for k, v in aws_cloudwatch_metric_alarm.this : k => v.arn
  }
}