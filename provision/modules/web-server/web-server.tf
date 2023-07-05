# EC2 instance for the web server
resource "aws_instance" "main" {
  ami           = var.ami
  instance_type = var.instance_types["main"]

  availability_zone      = var.availability_zone
  subnet_id              = var.subnet_id
  private_ip             = var.private_ips["main"]
  vpc_security_group_ids = [aws_security_group.main.id]
  key_name               = var.ssh_key_name

  tags = {
    Name = var.names["main"]
  }
}

# EC2 instance for the container service
resource "aws_instance" "container" {
  ami           = var.ami
  instance_type = var.instance_types["container"]

  availability_zone      = var.availability_zone
  subnet_id              = var.subnet_id
  private_ip             = var.private_ips["container"]
  # vpc_security_group_ids = [aws_security_group.container.id]
  key_name               = var.ssh_key_name

  tags = {
    Name = var.names["container"]
  }
}

resource "aws_security_group" "main" {
  name        = "${var.names["main"]}-sg"
  vpc_id      = var.vpc_id
  description = "Security group for the web server"

  tags = {
    Name = var.names["main"]
  }
}

resource "aws_security_group" "container" {
  name        = "${var.names["container"]}-sg"
  vpc_id      = var.vpc_id
  description = "Security group for the container"

  tags = {
    Name = var.names["container"]
  }
}

# TODO: add security group for container service
# See if I can reuse the same security group for the container service, with something like
# https://stackoverflow.com/questions/72871233/how-to-add-security-group-rule-to-multiple-security-groups



resource "aws_security_group_rule" "allow_http_incoming" {
  type              = "ingress"
  security_group_id = aws_security_group.main.id

  from_port   = local.http_port
  to_port     = local.http_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_https_incoming" {
  type              = "ingress"
  security_group_id = aws_security_group.main.id

  from_port   = local.https_port
  to_port     = local.https_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_ssh_incoming" {
  type              = "ingress"
  security_group_id = aws_security_group.main.id

  from_port   = local.ssh_port
  to_port     = local.ssh_port
  protocol    = local.tcp_protocol
  cidr_blocks = var.public_cidr
}

resource "aws_security_group_rule" "allow_all_outgoing" {
  type              = "egress"
  security_group_id = aws_security_group.main.id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}

locals {
  http_port      = 80
  https_port     = 443
  ssh_port       = 22
  any_port       = 0
  tcp_protocol   = "tcp"
  any_protocol   = "-1"
  all_ips        = ["0.0.0.0/0"]
}
