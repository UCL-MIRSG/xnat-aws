resource "aws_db_instance" "db" {
  identifier_prefix     = "xnat-db" # for some reason, this doesn't work with `var.name`
  db_name               = var.name
  instance_class        = "db.${var.instance_type}"
  allocated_storage     = 15
  max_allocated_storage = 30
  engine                = "postgres"
  engine_version        = "14"

  username = local.db_username
  # TODO: should we use Secrets Manager to store the password?
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance#managed-master-passwords-via-secrets-manager-default-kms-key
  password = random_password.db_credentials.result

  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [aws_security_group.db.id]

  tags = {
    Name = var.name
  }
}

resource "random_password" "db_credentials" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
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
