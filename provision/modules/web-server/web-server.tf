locals {
  name           = "xnat_web"
  http_port      = 80
  https_port     = 443
  ssh_port       = 22
  container_port = 2376
  any_port       = 0
  tcp_protocol   = "tcp"
  any_protocol   = "-1"
  all_ips        = ["0.0.0.0/0"]
}

# EC2 instances
resource "aws_instance" "xnat_web" {

  ami               = var.ami
  instance_type     = var.instance_type
  availability_zone = var.availability_zone
  subnet_id         = var.subnet_id
  private_ip        = var.private_ip
  key_name          = var.ssh_key_name

  vpc_security_group_ids = [aws_security_group.sg.id]

  root_block_device {
    volume_size = var.root_block_device_size
  }

  tags = {
    Name = local.name
  }
}

# Security groups
resource "aws_security_group" "sg" {
  name        = "${local.name}-sg"
  vpc_id      = var.vpc_id
  description = "Security group for the ${local.name} server"

  tags = {
    Name = local.name
  }
}


# Security group rules ------------------------------------------------------------------------
resource "aws_security_group_rule" "allow_ssh_incoming" {
  type              = "ingress"
  security_group_id = aws_security_group.sg.id

  from_port   = local.ssh_port
  to_port     = local.ssh_port
  protocol    = local.tcp_protocol
  cidr_blocks = var.ssh_cidr
}

resource "aws_security_group_rule" "allow_all_outgoing" {
  type              = "egress"
  security_group_id = aws_security_group.sg.id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_http_incoming" {
  type              = "ingress"
  security_group_id = aws_security_group.sg.id

  from_port   = local.http_port
  to_port     = local.http_port
  protocol    = local.tcp_protocol
  cidr_blocks = var.http_cidr
}

resource "aws_security_group_rule" "allow_https_incoming" {
  type              = "ingress"
  security_group_id = aws_security_group.sg.id

  from_port   = local.https_port
  to_port     = local.https_port
  protocol    = local.any_protocol
  cidr_blocks = var.https_cidr
}
