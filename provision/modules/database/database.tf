resource "aws_db_subnet_group" "xnat-db" {
  name       = "xnat-db"
  subnet_ids = var.subnet_ids

  tags = {
    Name = var.name
  }
}

resource "aws_db_instance" "db" {
  identifier_prefix     = "${local.identifier_prefix}-"
  db_name               = local.db_name
  instance_class        = var.instance_type
  allocated_storage     = 15
  max_allocated_storage = 30
  engine                = "postgres"
  engine_version        = local.postgres_version
  parameter_group_name  = aws_db_parameter_group.db-parameters.name
  apply_immediately     = true

  username = local.db_username
  password = random_password.db_credentials.result

  availability_zone      = var.availability_zone
  db_subnet_group_name   = aws_db_subnet_group.xnat-db.name
  vpc_security_group_ids = [aws_security_group.db.id]

  skip_final_snapshot = true

  tags = {
    Name = var.name
  }
}

resource "random_password" "db_credentials" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]<>:?"
}

# Write the passwords to file and encrypt the vault
resource "local_sensitive_file" "ansible-vault" {

  content = templatefile("templates/ansible_vault.tftpl", {
    postgres_xnat_password = random_password.db_credentials.result
  })
  filename        = local.ansible_vault_file
  file_permission = "0644"

  provisioner "local-exec" {
    command = "ansible-vault encrypt ${local.ansible_vault_file} --vault-password ${local.encryption_password_file}"
  }

}

# Security group for the database
resource "aws_security_group" "db" {
  name        = "${var.name}-sg"
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

# Define Database parameter group to force connections to use SSL
resource "aws_db_parameter_group" "db-parameters" {
  name   = "${local.db_name}-db-parameters"
  family = "postgres${local.postgres_version}"

  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  # Required for modifications that force re-creation of an in-use parameter group
  lifecycle {
    create_before_destroy = true
  }
}

locals {
  postgres_version         = "14"
  identifier_prefix        = replace("${var.name}", "_", "-")
  db_name                  = "xnat"
  db_username              = "xnat"
  postgres_port            = 5432
  any_port                 = 0
  tcp_protocol             = "tcp"
  any_protocol             = "-1"
  all_ips                  = ["0.0.0.0/0"]
  ansible_vault_file       = "../configure/group_vars/web/vault"
  encryption_password_file = "../configure/.vault_password"
}
