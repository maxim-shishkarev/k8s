resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name  = "${var.name}-vpc"
    Owner = var.owner
  }
}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  count             = length(var.zones)
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, 1 + count.index)
  availability_zone = format("%s${var.zones[count.index]}", var.region)
  map_public_ip_on_launch = true

  tags = {
    Name  = "${var.name}-${var.zones[count.index]}"
    Owner = var.owner
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name  = "${var.name}-igw"
    Owner = var.owner
  }
}

resource "aws_route_table" "igw" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.igw_default_route
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name  = "${var.name}-igw-route"
    Owner = var.owner
  }
}

resource "aws_route_table_association" "main" {
  count          = length(var.zones)
  subnet_id      = aws_subnet.main[count.index].id
  route_table_id = aws_route_table.igw.id
}

resource "aws_security_group" "any_from_myip" {
  name        = "${var.name}-ingress-any_from_myip"
  description = "Ingress: Allow ANY from My IP address"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Ingress: Allow ANY from MyIP"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.myip]
  }

  tags = {
    name  = "${var.name}-ingress-any_from_myip"
    Owner = var.owner
  }
}

resource "aws_security_group" "any_to_any" {
  name        = "${var.name}-egress-any_to_any"
  description = "Egress: Allow ANY to ANY"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "Egress: Allow ANY to ANY"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.anyip]
  }

  tags = {
    Name  = "${var.name}-egress-any_to_any"
    Owner = var.owner
  }
}

output "Region" {
  value = var.region
}

output "VPC_Name" {
  value = lookup(aws_vpc.main.tags, "Name")
}

output "VPC_ID" {
  value = aws_vpc.main.id
}

output "VPC_CIDR" {
  value = "${aws_vpc.main.cidr_block}"
}

output "VPC_ARN" {
  value = "${aws_vpc.main.arn}"
}

output "Subnets_CIDR" {
  value = "${aws_subnet.main[*].cidr_block}"
}

output "Subnets_IDs" {
  value = "${aws_subnet.main[*].id}"
}

output "MyIP" {
  value = var.myip
}