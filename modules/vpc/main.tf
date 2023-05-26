# Create a VPC
resource "aws_vpc" "agharameezvpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(var.tags, {
    "Name" = "AghaRameez-VPC"
    }
  )
}
# Create a internetgateway
resource "aws_internet_gateway" "agharameezgw" {
  vpc_id = aws_vpc.agharameezvpc.id
  tags = merge(var.tags, {
    "Name" = "AghaRameez-IGW"
    }
  )
}

data "aws_availability_zones" "azs" {

}

# Elastic Ip for NAT
resource "aws_eip" "nat_eip" {
  count      = (length(var.privateprefix) <= length(data.aws_availability_zones.azs) ? length(data.aws_availability_zones.azs.names) : length(var.publicprefix))
  vpc        = true
  depends_on = [aws_internet_gateway.agharameezgw]

}


# Create a NAT
resource "aws_nat_gateway" "nat" {
  depends_on    = [aws_subnet.main-Private-subnet, data.aws_availability_zones.azs]
  count         = (length(var.privateprefix) <= length(data.aws_availability_zones.azs) ? length(data.aws_availability_zones.azs.names) : length(var.publicprefix))
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.main-Public-subnet[count.index].id
  tags = merge(var.tags, {
    "Name" = "AghaRameez-nat${count.index}"
    }
  )
}

# Create a Main Public Subnet
resource "aws_subnet" "main-Public-subnet" {
  count             = length(var.publicprefix)
  cidr_block        = var.publicprefix[count.index]
  vpc_id            = aws_vpc.agharameezvpc.id
  availability_zone = element(data.aws_availability_zones.azs.names, count.index % length(var.publicprefix))
  tags = merge(var.tags, {
    "Name" = "AghaRameez-PublicSubnet-${count.index}"
    }
  )
}

# Create a Main Private Subnet
resource "aws_subnet" "main-Private-subnet" {
  count             = length(var.privateprefix)
  cidr_block        = var.privateprefix[count.index]
  vpc_id            = aws_vpc.agharameezvpc.id
  availability_zone = element(data.aws_availability_zones.azs.names, count.index % length(var.privateprefix))
  tags = merge(var.tags, {
    "Name" = "AghaRameez-PrivateSubnet-${count.index}"
    }
  )
}
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.agharameezvpc.id
  tags = merge(var.tags, {
    "Name" = "AghaRameez-PublicRT"
    }
  )
}

resource "aws_route_table" "private_route_table" {
  count  = (length(var.privateprefix) <= length(data.aws_availability_zones.azs) ? length(data.aws_availability_zones.azs.names) : length(var.publicprefix))
  vpc_id = aws_vpc.agharameezvpc.id
  tags = merge(var.tags, {
    "Name" = "AghaRameez-PrivateRT-${count.index}"
    }
  )
}
# Create a Public Route
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.agharameezgw.id
}
# # # Create a Private Route
resource "aws_route" "private_route" {
  count                  = (length(var.privateprefix) <= length(data.aws_availability_zones.azs) ? length(data.aws_availability_zones.azs.names) : length(var.publicprefix))
  route_table_id         = aws_route_table.private_route_table[count.index].id
  destination_cidr_block = aws_subnet.main-Public-subnet[count.index].cidr_block
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id
}
resource "aws_route_table_association" "public_subnet_association" {
  count          = length(aws_subnet.main-Public-subnet)
  subnet_id      = aws_subnet.main-Public-subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_association" {
  count          = length(aws_subnet.main-Private-subnet)
  subnet_id      = aws_subnet.main-Private-subnet[count.index].id
  route_table_id = element(aws_route_table.private_route_table.*.id, count.index % length(var.privateprefix))
}
# # Create a security Group
# resource "aws_security_group" "agharameezSG" {
#   name_prefix = "agharameez"
#   vpc_id      = aws_vpc.agharameezvpc.id

#   ingress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]

#   }
# }
