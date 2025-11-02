locals {
  name_prefix = replace(lower(var.name), "/[^a-z0-9-]/", "-")
}

# Create Secuiry Group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "${local.name_prefix}-alb_sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = var.enable_https ? [1] : []
    content {
      description = "Allow HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    "Name" = "${local.name_prefix}-alb_sg"
  })
}

# Create Application Load Balancer
resource "aws_lb" "this" {
  name               = "${local.name_prefix}-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids
  internal           = false
  idle_timeout       = 60 // in seconds

  enable_deletion_protection = false

  tags = merge(var.tags, {
    Name = "alb-${local.name_prefix}"
  })
}

# Create Target Group for ALB
resource "aws_lb_target_group" "this" {
  name        = "${local.name_prefix}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = var.target_type

  health_check {
    path                = var.health_check_path
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5 // in seconds
    matcher             = "200-399"
  }

  tags = merge(var.tags, {
    Name = "tg-${local.name_prefix}"
  })
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = {
    for k, v in var.target_instance_ids : k => v
  }

  target_group_arn = aws_lb_target_group.this.arn
  target_id        = each.value
  port             = 80
}

# Listeners for ALB
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

# HTTPS Listener (optional)
resource "aws_lb_listener" "https" {
  count             = var.enable_https ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.https_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}