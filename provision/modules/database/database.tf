resource "aws_db_subnet_group" "default" {
  name       = var.name
  subnet_ids = [var.subnet_id]
  tags = {
    Name = "DB subnet group for ${var.name}"
  }
}

resource "aws_db_instance" "db" {
  db_name = var.name
  # TODO: do we need storage autoscaling? Can be set using `max_allocated_storage`
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance#storage-autoscaling
  instance_class    = "db.${var.instance_type}"
  allocated_storage = 10
  engine            = "postgres"
  engine_version    = "14"

  username = local.db_username
  # TODO: should we use Secrets Manager to store the password?
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance#managed-master-passwords-via-secrets-manager-default-kms-key
  password = random_password.db_credentials.result

  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.db.id]
}

resource "random_password" "db_credentials" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Database parameter group, enable logging
resource "aws_db_parameter_group" "db" {
  name   = var.name
  family = "postgres14"

  parameter {
    name  = "log_connections"
    value = "1"
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
  db_username   = "xnat"
  postgres_port = 5432
  any_port      = 0
  tcp_protocol  = "tcp"
  any_protocol  = "-1"
  all_ips       = ["0.0.0.0/0"]
}
