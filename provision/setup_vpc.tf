
# Set up VPC, subnets, internet gateway, and security groups

# Set up VPC
resource "aws_vpc" "xnat" {
  cidr_block           = "192.168.0.0/16"
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
  cidr_block              = "192.168.56.0/24"
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
    cidr_block = "0.0.0.0/0" # all traffic that is not internal (that does not match vpc range)
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

# Set up private subnet
resource "aws_subnet" "xnat-private" {
  vpc_id                  = aws_vpc.xnat.id
  cidr_block              = "192.168.57.0/24"
  map_public_ip_on_launch = false
  availability_zone       = var.availability_zone
  tags = {
    Name = "xnat-public"
  }
}

# NAT Gateway to allow private subnet to connect to the internet
resource "aws_eip" "nat_gateway" {
  domain = "vpc"
}
resource "aws_nat_gateway" "xnat-nat-gateway" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.xnat-private.id

  tags = {
    Name = "xnat"
  }

  # To ensure proper ordering, add Internet Gateway as dependency
  depends_on = [aws_internet_gateway.xnat-internet-gateway]

}

# Private route tables
resource "aws_route_table" "xnat-private" {

  vpc_id = aws_vpc.xnat.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.xnat-nat-gateway.id
  }

  tags = {
    Name = "xnat-private"
  }

}

resource "aws_route_table_association" "xnat-private" {
  subnet_id      = aws_subnet.xnat-private.id
  route_table_id = aws_route_table.xnat-private.id
}

# Setup security groups
resource "aws_security_group" "xnat-web" {

  vpc_id      = aws_vpc.xnat.id
  description = "security group for the web server"

  # Allow incoming HTTP traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow incoming HTTPS traffic
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outgoing traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH into the instance
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [module.get_my_ip.my_public_cidr]
  }

  tags = {
    Name = "xnat-web"
  }

}

resource "aws_security_group" "bastion" {

  vpc_id      = aws_vpc.xnat.id
  description = "security group for bastion that allows ssh and all egress traffic"

  # Allow outgoing traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH into the instance
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [module.get_my_ip.my_public_cidr]
  }
  tags = {
    Name = "bastion"
  }
}

resource "aws_security_group" "xnat-db" {

  vpc_id      = aws_vpc.xnat.id
  description = "security group for the database that allows SSH from bastion"

  # Allow outgoing traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH into the instance
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion.id, ] # only allow connection from bastion
  }

  # Allow connection to postgres port
  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [aws_security_group.xnat-web.id] # only allow connection from web server
  }

  tags = {
    Name = "xnat-db"
  }

}
