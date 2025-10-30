resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "SG for ${var.name}"
  vpc_id      = var.vpc_id

  # SSh optional 
  dynamic "ingress" {
    for_each = length(var.ingress_cidr_blocks) > 0 ? [1] : []
    content {
      description = "SSH access cidr_blocks"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ingress_cidr_blocks
    }
  }

  # Additional Ingress Rules
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

  tags = merge(var.tags, {
    Name = "${var.name}-sg"
  })
}

// Iam for ec2 instance
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

// create iam role
resource "aws_iam_role" "this" {
  name               = "${var.name}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

// Managed Policy 
resource "aws_iam_role_policy_attachment" "policy_attachment" {
  count      = length(var.iam_policy_arns)
  role       = aws_iam_role.this.name
  policy_arn = var.iam_policy_arns[count.index]
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.name}-instance-profile-ec2"
  role = aws_iam_role.this.name
}

resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  associate_public_ip_address = var.associate_public_ip
  security_groups             = [aws_security_group.this.id]

  iam_instance_profile = aws_iam_instance_profile.this.name
  user_data            = var.user_data

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  tags = var.tags
}