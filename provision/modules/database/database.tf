# Launch ec2 instance for the database
resource "aws_instance" "xnat_db" {
  ami           = var.ami
  instance_type = var.instance_type

  availability_zone      = var.availability_zone
  subnet_id              = var.subnet_id
  private_ip             = var.private_ip
  vpc_security_group_ids = [aws_security_group.xnat-db.id]
  key_name               = var.ssh_key_name

  tags = {
    Name = var.name
  }
}

# Set up security groups
resource "aws_security_group" "xnat-db" {

  vpc_id      = var.vpc_id
  description = "security group for the database"

  # Allow outgoing traffic
  egress {
    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = local.any_protocol
    cidr_blocks = local.all_ips
  }

  # Allow SSH into the instance
  ingress {
    from_port   = local.ssh_port
    to_port     = local.ssh_port
    protocol    = local.tcp_protocol
    cidr_blocks = var.public_cidr
  }

  # Allow connection to postgres port
  ingress {
    from_port       = local.postgres_port
    to_port         = local.postgres_port
    protocol        = local.tcp_protocol
    security_groups = [var.webserver_sg_id] # only allow connection from web server
  }

  tags = {
    Name = var.name
  }

}

locals {
  ssh_port       = 22
  postgres_port  = 5432
  any_port       = 0
  tcp_protocol   = "tcp"
  any_protocol   = "-1"
  all_ips        = ["0.0.0.0/0"]
}
