locals {
  name           = "xnat_cserv"
  ssh_port       = 22
  container_port = 2376
  any_port       = 0
  tcp_protocol   = "tcp"
  any_protocol   = "-1"
  all_ips        = ["0.0.0.0/0"]
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

# Common rules
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

resource "aws_security_group_rule" "allow_container_incoming" {
  type              = "ingress"
  security_group_id = aws_security_group.sg.id

  from_port                = local.container_port
  to_port                  = local.container_port
  protocol                 = local.tcp_protocol
  source_security_group_id = var.webserver_sg_id # only allow connection from web server
}
