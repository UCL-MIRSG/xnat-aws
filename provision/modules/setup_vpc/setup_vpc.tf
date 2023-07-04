
# Set up VPC, subnets, internet gateway, and security groups

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
    cidr_blocks = var.public_cidr
  }

  tags = {
    Name = "xnat-web"
  }

}

resource "aws_security_group" "xnat-db" {

  vpc_id      = aws_vpc.xnat.id
  description = "security group for the database"

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
    cidr_blocks = var.public_cidr
  }

  # Allow connection to postgres port
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.xnat-web.id] # only allow connection from web server
  }

  tags = {
    Name = "xnat-db"
  }

}

resource "aws_security_group" "xnat-cserv" {

  vpc_id      = aws_vpc.xnat.id
  description = "security group for the Container Service"

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
    cidr_blocks = var.public_cidr
  }

  # Allow connection to Container Service port
  ingress {
    from_port       = 2376
    to_port         = 2376
    protocol        = "tcp"
    security_groups = [aws_security_group.xnat-web.id] # only allow connection from web server
  }

  tags = {
    Name = "xnat-cserv"
  }

}
