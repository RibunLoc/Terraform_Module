output "vpc_id" {
  description = "ID of your vpc"
  value       = aws_vpc.this.id
}

output "public_subnets_ids" {
  description = "List of VPC Public Subnet IDs"
  value       = values(aws_subnet.public)[*].id
}

output "private_subnets_ids" {
  description = "List of VPC Private Subnet IDs"
  value       = values(aws_subnet.private)[*].id
}

output "nat_gateway_id" {
  description = "ID Nat Gateway"
  value       = var.enable_nat_gateway ? aws_nat_gateway.nat[0].id : null
}

output "security_group_default_id" {
  description = "ID of the default security group"
  value       = aws_security_group.default.id
}

output "public_subnets_cidr_blocks" {
  description = "List CIDR of public subnet"
  value       = values(aws_subnet.public)[*].cidr_block
}

output "private_subnets_cidr_blocks" {
  description = "List CIDR of private subnet"
  value       = values(aws_subnet.private)[*].cidr_block
}

output "ssm_interface_endpoint_ids" {
  description = "IDs of 3 interface endpoints for SSM"
  value       = [for k, ep in aws_vpc_endpoint.ssm_interface : ep.id]
}

output "ssm_interface_endpoint_dns" {
  description = "DNS names of interface endpoints"
  value       = [for k, ep in aws_vpc_endpoint.ssm_interface : ep.dns_entry]
}

output "s3_gateway_endpoint_id" {
  description = "ID of Gateway s3 endpoint"
  value       = try(aws_vpc_endpoint.s3_gateway[0].id, null)
}