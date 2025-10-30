// 1. Create IAM Role
resource "aws_iam_role" "ec2_role" {
  name               = var.role_name
  assume_role_policy = var.assume_role_policy
  description        = "IAM Role for EC2 Instance with name ${var.role_name}"

  tags = merge(var.tags, {
    Name = "${var.role_name}-ec2-role"
  })
}

// 2. Attach Managed Policies to the Role
resource "aws_iam_role_policy_attachment" "policy_attachments" {
  count      = length(var.policy_arns)
  role       = aws_iam_role.ec2_role.name
  policy_arn = var.policy_arns[count.index]
}

// 3. Create IAM Instance Profiile 
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = var.role_name
  role = aws_iam_role.ec2_role.name
}