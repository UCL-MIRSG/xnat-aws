
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
resource "aws_security_group" "allow-ssh-and-incoming" {

  #vpc_id = data.aws_vpc.default.id
  vpc_id      = aws_vpc.xnat.id
  description = "security group that allows ssh as well as all ingress and egress traffic"

  # Allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
}

resource "aws_security_group" "allow-ssh-and-postgres" {

  vpc_id      = aws_vpc.xnat.id
  description = "security group that allows ssh and connection to postgres post, and all egress traffic"

  # Allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow connection to postgres port
  ingress {
    from_port   = 5432
    to_port     = 5432
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
}

resource "aws_security_group" "allow-ssh-only" {

  vpc_id      = aws_vpc.xnat.id
  description = "security group that allows ssh and all egress traffic"

  # Allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
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
}
