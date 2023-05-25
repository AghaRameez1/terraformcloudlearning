

# Create a VPC
resource "aws_vpc" "agharameezvpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    "Name" = "${var.tags}-VPC"
  }
}
#Create a internetgateway
resource "aws_internet_gateway" "agharameezgw" {
  vpc_id = aws_vpc.agharameezvpc.id
  tags = {
    "Name" = "${var.tags}-igw"
  }
}

# Elastic Ip for NAT
resource "aws_eip" "nat_eip" {
  for_each   = var.privateprefix
  vpc        = true
  depends_on = [aws_internet_gateway.agharameezgw]

}

# Create a NAT
resource "aws_nat_gateway" "nat" {
  depends_on    = [aws_subnet.main-Public-subnet]
  for_each      = var.privateprefix
  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id     = aws_subnet.main-Public-subnet[each.key].id
  tags = {
    "Name" = "${var.tags}-NatGateway--${each.key}"
  }
}

# Create a Main Public Subnet
resource "aws_subnet" "main-Public-subnet" {
  for_each          = var.publicprefix
  cidr_block        = each.value["cidr"]
  vpc_id            = aws_vpc.agharameezvpc.id
  availability_zone = each.value["az"]
  tags = {
    "Name" = "${var.tags}-PublicSubnet--${each.key}"
  }
}

# Create a Main Private Subnet
resource "aws_subnet" "main-Private-subnet" {
  for_each          = var.privateprefix
  cidr_block        = each.value["cidr"]
  vpc_id            = aws_vpc.agharameezvpc.id
  availability_zone = each.value["az"]
  tags = {
    "Name" = "${var.tags}-PrivateSubnet--${each.key}"
  }
}
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.agharameezvpc.id
  tags = {
    Name = "${var.tags}-Public Route Table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.agharameezvpc.id
  tags = {
    Name = "${var.tags}-Private Route Table"
  }
}
# Create a Public Route
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.agharameezgw.id
}
# # Create a Private Route
resource "aws_route" "private_route" {
  for_each               = var.privateprefix
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = aws_subnet.main-Public-subnet[each.key].cidr_block
  nat_gateway_id         = aws_nat_gateway.nat[each.key].id
}
resource "aws_route_table_association" "public_subnet_association" {
  for_each       = aws_subnet.main-Public-subnet
  subnet_id      = each.value["id"]
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_association" {
  for_each       = aws_subnet.main-Private-subnet
  subnet_id      = each.value["id"]
  route_table_id = aws_route_table.private_route_table.id
}
# Create a security Group
resource "aws_security_group" "agharameezSG" {
  name_prefix = "agharameez"
  vpc_id      = aws_vpc.agharameezvpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}
