output "instance_profile_name" {
  description = "Name of IAM Intance Profile created, using to assign to EC2"
  value       = aws_iam_instance_profile.ec2_instance_profile.name
}

output "role_arn" {
  description = "ARN of IAM Role created"
  value       = aws_iam_role.ec2_role.arn
}