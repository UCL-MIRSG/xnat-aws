
# Set up VPC, subnets, internet gateway, and security groups
resource "aws_vpc" "xnat" {
  cidr_block           = "192.168.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  #enable_classiclink   = false
  tags = {
    Name = "xnat"
  }
}

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
resource "aws_internet_gateway" "xnat-gateway" {
  vpc_id = aws_vpc.xnat.id
  tags = {
    Name = "xnat"
  }
}

# Route tables
resource "aws_route_table" "xnat-public" {
  vpc_id = aws_vpc.xnat.id
  route {
    cidr_block = "0.0.0.0/0" # all traffic that is not internal (that does not match vpc range)
    gateway_id = aws_internet_gateway.xnat-gateway.id
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
resource "aws_security_group" "web-server" {

  vpc_id      = aws_vpc.xnat.id
  description = "security group for the web server"

  # Allow incoming traffic
  ingress {
    from_port   = 80
    to_port     = 80
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

}

resource "aws_security_group" "database" {

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
    cidr_blocks = [module.get_my_ip.my_public_cidr]
  }

  # Allow connection to postgres port
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.xnat-public.cidr_block] # only allow connection from public subnet
  }

}
