# Set up security groups
resource "aws_security_group" "xnat-web" {

  vpc_id      = var.vpc_id
  description = "security group for the web server"

  tags = {
    Name = "xnat-web"
  }
}

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
    security_groups = [aws_security_group.xnat-web.id] # only allow connection from web server
  }

  tags = {
    Name = "xnat-db"
  }

}

resource "aws_security_group" "xnat-cserv" {

  vpc_id      = var.vpc_id
  description = "security group for the Container Service"

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

  # Allow connection to Container Service port
  ingress {
    from_port       = local.container_port
    to_port         = local.container_port
    protocol        = local.tcp_protocol
    security_groups = [aws_security_group.xnat-web.id] # only allow connection from web server
  }

  tags = {
    Name = "xnat-cserv"
  }

}

# Set up security group rules
resource "aws_security_group_rule" "allow_http_incoming" {
  type              = "ingress"
  security_group_id = aws_security_group.xnat-web.id

  from_port   = local.http_port
  to_port     = local.http_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_https_incoming" {
  type              = "ingress"
  security_group_id = aws_security_group.xnat-web.id

  from_port   = local.https_port
  to_port     = local.https_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_ssh_incoming" {
  type              = "ingress"
  security_group_id = aws_security_group.xnat-web.id

  from_port   = local.ssh_port
  to_port     = local.ssh_port
  protocol    = local.tcp_protocol
  cidr_blocks = var.public_cidr
}

resource "aws_security_group_rule" "allow_all_outgoing" {
  type              = "egress"
  security_group_id = aws_security_group.xnat-web.id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}

locals {
  http_port      = 80
  https_port     = 443
  ssh_port       = 22
  postgres_port  = 5432
  container_port = 2376
  any_port       = 0
  tcp_protocol   = "tcp"
  any_protocol   = "-1"
  all_ips        = ["0.0.0.0/0"]
}
