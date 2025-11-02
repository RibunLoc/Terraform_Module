data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_region" "current" {}

locals {
  az_names = slice(data.aws_availability_zones.available.names, 0, min(var.az_count, length(data.aws_availability_zones.available.names)))
  az_index_map = {
    for idx, az in local.az_names : az => idx
  }

  # provide 3 services endpoints for ssm
  ssm_interface_services = [
    "com.amazonaws.${data.aws_region.current.name}.ssm",
    "com.amazonaws.${data.aws_region.current.name}.ssmmessages",
    "com.amazonaws.${data.aws_region.current.name}.ec2messages",
  ]

}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags,
    {
      Name = "${var.name}-vpc"
  })
}

# Internet Gateway 
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name}-igw"
  })
}

# Public subnet 
resource "aws_subnet" "public" {
  for_each                = local.az_index_map
  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.key
  map_public_ip_on_launch = true
  cidr_block              = cidrsubnet(var.cidr_block, 8, each.value)

  tags = merge(var.tags, {
    Name = "${var.name}-public-subnet-${each.value + 1}"
  })
}

# Private subnet
resource "aws_subnet" "private" {
  for_each          = local.az_index_map
  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(var.cidr_block, 8, each.value + 10)

  tags = merge(var.tags, {
    Name = "${var.name}-private-subnet-${each.value + 1}"
  })
}

# Public Route Table 
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name}-public-rt"
  })
}

# Route internet access
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.name}-nat-eip"
  })
}

resource "aws_nat_gateway" "nat" {
  count         = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[local.az_names[0]].id
  depends_on    = [aws_internet_gateway.igw]
  tags          = merge(var.tags, { Name = "${var.name}-nat-gateway" })
}

# Private Route Table 
resource "aws_route_table" "private" {
  count  = var.enable_nat_gateway ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name}-private-rt"
  })
}

resource "aws_route" "private_nat_access" {
  count                  = var.enable_nat_gateway ? 1 : 0
  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[0].id
}

resource "aws_route_table_association" "private_assoc" {
  for_each       = var.enable_nat_gateway ? aws_subnet.private : {}
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[0].id
}

# Security Group for Endpoints 
resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.name}-vpce-sg"
  description = "Security group for VPC Endpoints"
  vpc_id      = aws_vpc.this.id

  # Allow all inbound traffic from VPC CIDR to ENI endpoints (HTTPS)
  ingress {
    description = "VPC to VPC endpoints (443)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.this.cidr_block]
  }

  # Additional if needed
  dynamic "ingress" {
    for_each = var.endpoint_security_group_additional_ingress_cidrs
    content {
      description = "Additional CIDR to VPC endpoint (443)"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
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
    Name = "${var.name}-vpc-endpoint-sg"
  })
}

# VPC Interface Endpoint for SSm
resource "aws_vpc_endpoint" "ssm_interface" {
  for_each            = var.enable_ssm_endpoints ? toset(local.ssm_interface_services) : []
  vpc_id              = aws_vpc.this.id
  service_name        = each.value
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  # Should place ENI in these subnets 
  subnet_ids = var.ssm_endpoints_subnet_ids

  security_group_ids = [aws_security_group.vpc_endpoints.id]

  # Hold ipv4 addresses for ENI 
  ip_address_type = "ipv4"

  dns_options {
    dns_record_ip_type = "ipv4"
  }

  tags = merge(var.tags, {
    Name = "${var.name}-vpc-endpoint-${replace(each.value, ".", "-")}"
  })
}

# S3 gateway endpoint to access internal s3 (Not traverse internet)
resource "aws_vpc_endpoint" "s3_gateway" {
  count             = var.enable_s3_gateway_endpoint ? 1 : 0
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = var.private_route_table_ids

  tags = merge(var.tags, {
    Name = "${var.name}-s3-gateway-endpoint"
  })
}

