# Launch ec2 instance for the database
resource "aws_instance" "db" {
  ami           = var.ami
  instance_type = var.instance_type

  availability_zone      = var.availability_zone
  subnet_id              = var.subnet_id
  private_ip             = var.private_ip
  vpc_security_group_ids = [aws_security_group.db.id]
  key_name               = var.ssh_key_name

  root_block_device {
    volume_size = var.root_block_device_size
  }

  tags = {
    Name = var.name
  }
}

# Security group for the database
resource "aws_security_group" "db" {
  vpc_id      = var.vpc_id
  description = "security group for the database"

  tags = {
    Name = var.name
  }
}

# Security group rules
resource "aws_security_group_rule" "allow_ssh_incoming" {
  type              = "ingress"
  security_group_id = aws_security_group.db.id

  from_port   = local.ssh_port
  to_port     = local.ssh_port
  protocol    = local.tcp_protocol
  cidr_blocks = var.ssh_cidr
}

resource "aws_security_group_rule" "allow_postgres_incoming" {
  type              = "ingress"
  security_group_id = aws_security_group.db.id

  from_port                = local.postgres_port
  to_port                  = local.postgres_port
  protocol                 = local.tcp_protocol
  source_security_group_id = var.webserver_sg_id # only allow connection from web server
}

resource "aws_security_group_rule" "allow_all_outgoing" {
  type              = "egress"
  security_group_id = aws_security_group.db.id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}

locals {
  ssh_port      = 22
  postgres_port = 5432
  any_port      = 0
  tcp_protocol  = "tcp"
  any_protocol  = "-1"
  all_ips       = ["0.0.0.0/0"]
}
