resource "aws_cloudwatch_log_group" "this" {
  count             = var.create_log_group ? 1 : 0
  name              = var.log_group_name
  retention_in_days = var.retention_in_days

  tags = var.tags
}

# Cloud metrics alarm
resource "aws_cloudwatch_metric_alarm" "this" {
  for_each = var.create_metric_alarm ? var.instance_id : {}

  alarm_name          = var.alarm_name
  comparison_operator = var.comparision_operator

  metric_name               = var.metric_name
  evaluation_periods        = 1
  namespace                 = var.namespace
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold
  alarm_description         = "This metric alarm was created by Terraform"
  insufficient_data_actions = var.sns_topic_arn != null ? [var.sns_topic_arn] : []


  dimensions = {
    InstanceId = each.value
  }

  tags = var.tags
}