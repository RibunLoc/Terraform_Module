locals {
  common_tags = merge(
    {
      Name = var.name
    },
    var.tags
  )

  user_data_rendered = base64encode(
    templatefile("${path.module}/templates/user_data.sh", var.user_data_vars)
  )
}

resource "aws_security_group" "this" {
  vpc_id = var.vpc_id
  dynamic "ingress" {
    for_each = var.additional_ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "this" {
  name_prefix            = "${var.name}-lt-"
  image_id               = var.ami_id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.this.id]

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  user_data = local.user_data_rendered
  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings

    content {
      device_name = value.device_name
      ebs {
        volume_size           = try(block_device_mappings.value.volume_size, 8)
        volume_type           = try(block_device_mappings.value.volume_type, "gp3")
        delete_on_termination = try(block_device_mappings.value.delete_on_termination, true)
        encrypted             = try(block_device_mappings.value.encrypted, false)
        iops                  = try(block_device_mappings.value.iops, null)
        throughput            = try(block_device_mappings.value.throughput, null)
      }
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tag_specifications {
    resource_type = "instance"
    tags          = local.common_tags
  }

  tags = local.common_tags
}

resource "aws_autoscaling_group" "this" {
  name                      = "${var.name}-asg"
  vpc_zone_identifier       = var.subnet_ids
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  health_check_type         = var.health_check_type
  health_check_grace_period = 300
  target_group_arns         = var.target_group_arns
  termination_policies      = ["OldestInstance", "OldestLaunchTemplate"] // scaling down select instance to terminate base on these policies
  capacity_rebalance        = true
  metrics_granularity       = "1Minute"

  dynamic "mixed_instances_policy" {
    for_each = var.mixed_instances.enabled ? [1] : []
    content {

      launch_template {
        launch_template_specification {
          launch_template_id = aws_launch_template.this.id
          version            = "$Latest"
        }
        dynamic "override" {
          for_each = try(var.mixed_instances.override_types, [])
          content {
            instance_type = override.value
          }
        }
      }

      instances_distribution {
        on_demand_base_capacity                  = try(var.mixed_instances.on_demand_base_capacity, 0)
        on_demand_percentage_above_base_capacity = try(var.mixed_instances.on_demand_percentage, 0)
        spot_max_price                           = try(var.mixed_instances.spot_max_price, null)
      }
    }
  }

  dynamic "instance_refresh" {
    for_each = var.enable_instance_refresh ? [1] : []
    content {
      strategy = "Rolling"
      preferences {
        min_healthy_percentage = 90
        instance_warmup        = 60
      }
      triggers = ["launch_template", "desired_capacity"]
    }
  }


  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [desired_capacity, launch_template[0].version]
  }

  dynamic "tag" {
    for_each = merge(local.common_tags, var.tags)
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

# Target Tracking (CPU Utilization) 
resource "aws_autoscaling_policy" "cpu_tgt" {
  count                  = var.cpu_target_percent == null ? 0 : 1
  name                   = "${var.name}-cpu-tgt-policy"
  autoscaling_group_name = aws_autoscaling_group.this.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu_target_percent
  }
}
