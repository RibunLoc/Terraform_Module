data "aws_ami" "base" {
  owners      = [var.base_ami_owner]
  most_recent = true
  filter {
    name   = "name"
    values = [var.base_ami_name_filter]
  }
}

resource "aws_imagebuilder_component" "install_nginx" {
  name     = "${var.name}-install-nginx"
  platform = "Linux"
  version  = "1.0.0"
  data     = <<YAML
name: install-nginx
schemaVersion: 1.0
phases:
  - name: build
    steps:
      - name: InstallNginx
        action: ExecuteBash
        inputs:
          commands:
            - apt-get update -y
            - apt-get install -y nginx
            - echo ok | sudo tee /usr/share/nginx/html/health
YAML
}

resource "aws_imagebuilder_image_recipe" "this" {
  name         = "${var.name}-recipe"
  version      = "1.0.0"
  parent_image = data.aws_ami.base.id
  component {
    component_arn = aws_imagebuilder_component.install_nginx.arn
  }
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "Test-ec2-role"
  role = aws_iam_role.image_builder_instance_role.name
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "image_builder_instance_role" {
  name               = "Test-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  component_arn = "arn:aws:imagebuilder:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:component/${aws_imagebuilder_component.install_nginx.name}/${aws_imagebuilder_component.install_nginx.version}/1"
}

resource "aws_iam_policy" "imagebuilder_components_read" {
  name = "imagebuilder-components-read"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "imagebuilder:GetComponent",
          "imagebuilder:GetComponentPolicy",
          "imagebuilder:ListComponentBuildVersions"
        ],
        Resource = [
          local.component_arn
          # hoặc "*" nếu bạn có nhiều component và muốn đỡ phải cập nhật
        ]
      },
      # Tuỳ nhu cầu: nếu component/recipe của bạn kéo file từ S3 hay tham chiếu SSM
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject", "s3:ListBucket"],
        Resource = ["*"]
      },
      {
        Effect   = "Allow",
        Action   = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParameterHistory"],
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_component_read" {
  role       = aws_iam_role.image_builder_instance_role.name
  policy_arn = aws_iam_policy.imagebuilder_components_read.arn
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = aws_iam_role.image_builder_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cw_logs" {
  role       = aws_iam_role.image_builder_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_imagebuilder_infrastructure_configuration" "this" {
  name                          = "${var.name}-infrastructure-configuration"
  subnet_id                     = var.subnet_id
  instance_types                = ["t3.small"]
  security_group_ids            = var.security_group_ids
  terminate_instance_on_failure = true
  instance_profile_name         = aws_iam_instance_profile.ec2_profile.name
  key_pair                      = "sshkeyVirginia"
}

resource "aws_imagebuilder_image" "this" {
  image_recipe_arn                 = aws_imagebuilder_image_recipe.this.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.this.arn
}