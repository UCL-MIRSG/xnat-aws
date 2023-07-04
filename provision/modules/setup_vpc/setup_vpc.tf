# Set up VPC
resource "aws_vpc" "xnat" {
  cidr_block           = var.cidr_blocks["vpc"]
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "xnat"
  }
}

# Set up public subnet
resource "aws_subnet" "xnat-public" {
  vpc_id                  = aws_vpc.xnat.id
  cidr_block              = var.cidr_blocks["public-subnet"]
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone
  tags = {
    Name = "xnat-public"
  }
}

# Internet gateway
resource "aws_internet_gateway" "xnat-internet-gateway" {
  vpc_id = aws_vpc.xnat.id
  tags = {
    Name = "xnat"
  }
}

# Public route tables
resource "aws_route_table" "xnat-public" {

  vpc_id = aws_vpc.xnat.id

  route {
    cidr_block = ["0.0.0.0/0"]
    gateway_id = aws_internet_gateway.xnat-internet-gateway.id
  }

  tags = {
    Name = "xnat-public"
  }

}

resource "aws_route_table_association" "xnat-public" {
  subnet_id      = aws_subnet.xnat-public.id
  route_table_id = aws_route_table.xnat-public.id
}
