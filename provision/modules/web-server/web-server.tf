locals {
  server_names   = ["main", "container"]
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
resource "aws_instance" "servers" {
  for_each = toset(local.server_names)

  ami               = var.ami
  instance_type     = var.instance_types[each.value]
  availability_zone = var.availability_zone
  subnet_id         = var.subnet_id
  private_ip        = var.private_ips[each.value]
  key_name          = var.ssh_key_name

  vpc_security_group_ids = [aws_security_group.sg[each.value].id]

  tags = {
    Name = var.names[each.value]
  }
}

# Security groups
resource "aws_security_group" "sg" {
  for_each    = toset(local.server_names)
  name        = "${var.names[each.value]}-sg"
  vpc_id      = var.vpc_id
  description = "Security group for the ${each.value} server"

  tags = {
    Name = var.names[each.value]
  }
}


# Security group rules ------------------------------------------------------------------------

# Common rules
resource "aws_security_group_rule" "allow_ssh_incoming" {
  for_each          = aws_security_group.sg
  type              = "ingress"
  security_group_id = each.value.id

  from_port   = local.ssh_port
  to_port     = local.ssh_port
  protocol    = local.tcp_protocol
  cidr_blocks = var.public_cidr
}

resource "aws_security_group_rule" "allow_all_outgoing" {
  for_each          = aws_security_group.sg
  type              = "egress"
  security_group_id = each.value.id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}


# Main server specific rules
resource "aws_security_group_rule" "allow_http_incoming" {
  type              = "ingress"
  security_group_id = aws_security_group.sg["main"].id

  from_port   = local.http_port
  to_port     = local.http_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_https_incoming" {
  type              = "ingress"
  security_group_id = aws_security_group.sg["main"].id

  from_port   = local.https_port
  to_port     = local.https_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}
