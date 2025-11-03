provider "aws" {
  region = var.region
}

locals {
  common_tags = {
    Project     = "MyTerraformLab"
    Managed     = "Terraform"
    Environment = "Dev"
  }
}

module "vpc" {
  source = "../../modules/VPC"

  name                       = "Dev-VPC"
  cidr_block                 = "10.0.0.0/16"
  enable_nat_gateway         = false
  az_count                   = 2
  enable_ssm_endpoints       = false
  enable_s3_gateway_endpoint = false
  ssm_endpoints_subnet_ids   = module.vpc.public_subnets_ids
}

# module "image_builder" {
#   source = "../../modules/image-builder"

#   base_ami_owner       = "099720109477" # Canonical
#   base_ami_name_filter = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
#   name                 = "dev-image-builder"
#   subnet_id            = module.vpc.public_subnets_ids[0]
#   security_group_ids   = [module.vpc.security_group_default_id]
# }

# data "aws_ami" "ubuntu" {
#   most_recent = true
#   owners      = ["099720109477"] // Canonical
#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
#   }
# }



# module "alb" {
#   source = "../../modules/application-load-balancer"

#   name              = "dev-alb"
#   vpc_id            = module.vpc.vpc_id
#   public_subnet_ids = module.vpc.public_subnets_ids
#   health_check_path = "/"
#   target_type       = "instance"
#   tags              = local.common_tags
# }


# module "web_asg" {
#   source     = "../../modules/auto-scaling-group"
#   name       = "dev-web"
#   subnet_ids = module.vpc.private_subnets_ids
#   vpc_id     = module.vpc.vpc_id
#   additional_ingress_rules = [
#     {
#       description = "Allow HTTP"
#       from_port   = 80
#       to_port     = 80
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#     }
#   ]

#   ami_id               = data.aws_ami.ubuntu.id
#   instance_type        = "t2.micro"
#   key_name             = "sshkeyVirginia"
#   iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

#   min_size         = 1
#   desired_capacity = 1
#   max_size         = 3

#   target_group_arns = [module.alb.target_group_arn]
#   health_check_type = "ELB"

#   user_data_vars = {
#     ENV = "dev"
#   }

#   mixed_instances = {
#     enabled              = true
#     on_demand_base       = 1
#     on_demand_percentage = 100
#     spot_max_price       = null
#     override_types       = ["t2.micro"]
#   }

#   cpu_target_percent = 55
#   tags = {
#     "Environment" = "dev"
#     "Service"     = "web"
#   }
# }


# module "database_MySQL" {
#   source = "../../modules/RDS"

#   name                   = "dev-mysql-db"
#   engine                 = "mysql"
#   engine_version         = "8.0.42"
#   instance_class         = "db.t3.micro"
#   port                   = 3306
#   allocated_storage      = 20
#   max_allocated_storage  = 0
#   storage_type           = "gp3"
#   multi_az               = false
#   parameter_group_family = "mysql8.0"

#   username = "admin"
#   password = "DevPassword"

#   allowed_cidr_blocks = module.vpc.public_subnets_cidr_blocks

#   backup_retention_days = 0
#   skip_final_snapshot   = true
#   deletion_protection   = false

#   vpc_id             = module.vpc.vpc_id
#   private_subnet_ids = module.vpc.private_subnets_ids


#   tags = local.common_tags
# }

# module "alb-ec2-public" {
#   source = "../../modules/application-load-balancer"

#   name                = "alb-dev-application"
#   vpc_id              = module.vpc.vpc_id
#   public_subnet_ids   = module.vpc.public_subnets_ids
#   health_check_path   = "/"
#   target_instance_ids = [module.ec2.instance_id]
#   tags                = local.common_tags
# }

# module "ec2_private" {
#   source = "../../modules/ec2-instance"

#   name = "dev-ec2-private"
#   vpc_id = module.vpc.vpc_id
#   key_name = "sshkeyVirginia"
#   subnet_id = tolist(module.vpc.private_subnets_ids)[0]
#   ami_id = "ami-0360c520857e3138f"
#   instance_type = "t2.micro"
#   associate_public_ip = false
#   ingress_cidr_blocks = [ "0.0.0.0/0" ]
#   additional_ingress_rules = [
#     {
#       description = "Allow Mysql from VPC"
#       from_port   = 3306
#       to_port = 3306
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#     }
#   ]
#   root_volume_size    = "10"

#   iam_policy_arns = [
#     "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
#     "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
#   ]

#   tags = merge(local.common_tags, {
#     Name = "dev-ec2-private"
#   })
# }

# module "ec2" {
#   source = "../../modules/ec2-instance"

#   name                = "dev-ec2-public"
#   vpc_id              = module.vpc.vpc_id
#   subnet_id           = tolist(module.vpc.public_subnets_ids)[0]
#   ami_id              = "ami-0360c520857e3138f"
#   ingress_cidr_blocks = ["0.0.0.0/0"]
#   additional_ingress_rules = [
#     {
#       description = "Allow HTTPS"
#       from_port   = 443
#       to_port     = 443
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#     },
#     {
#       description = "Allow Mysql from VPC"
#       from_port   = 3306
#       to_port     = 3306
#       protocol    = "tcp"
#       cidr_blocks = module.vpc.private_subnets_cidr_blocks
#     }
#   ]
#   key_name            = "sshkeyVirginia"
#   instance_type       = "t2.micro"
#   associate_public_ip = true
#   root_volume_size    = "10"

#   iam_policy_arns = [
#     "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
#     "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
#   ]

#   user_data = templatefile("${path.module}/../../scripts/install-agent-log-group.sh.tpl", {
#     region         = var.region,
#     log_group_name = "dev-log-group"
#   })

#   tags = merge(local.common_tags, {
#     Name = "dev-ec2-public"
#   })
# }

# module "app_monitoring" {
#   source              = "../../modules/cloud-watch"
#   create_log_group    = true
#   create_metric_alarm = false

#   log_group_name    = "dev-log-group"
#   retention_in_days = 14
# }

# module "high_cpu_alert_75" {
#   source              = "../../modules/cloud-watch"
#   create_log_group    = false
#   create_metric_alarm = true

#   namespace            = "AWS/EC2"
#   alarm_name           = "High-CPU-Utilization-Alarm"
#   metric_name          = "CPUUtilization"
#   threshold            = 75
#   comparision_operator = "GreaterThanOrEqualToThreshold"
#   period               = 60
#   sns_topic_arn        = "arn:aws:sns:us-east-1:140023408078:myWatchingEC2"
#   instance_id = {
#     "main" : module.ec2.instance_id
#   }

#   tags = local.common_tags
# }

# module "low_cpu_alert_25" {
#   source              = "../../modules/cloud-watch"
#   create_log_group    = false
#   create_metric_alarm = true

#   namespace            = "AWS/EC2"
#   alarm_name           = "Low-CPU-Utilization-Alarm"
#   metric_name          = "CPUUtilization"
#   threshold            = 25
#   comparision_operator = "LessThanOrEqualToThreshold"
#   period               = 60
#   sns_topic_arn        = "arn:aws:sns:us-east-1:140023408078:myWatchingEC2"
#   instance_id = {
#   "main" : module.ec2.instance_id }

#   tags = local.common_tags
# }