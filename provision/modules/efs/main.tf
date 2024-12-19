# Create an EFS and mount to public subnet
locals {
  # unique name to ensure idempotent file system creation
  name = "xnat-${var.vpc_id}-${var.subnet_id}"
}

# Security group to control access
resource "aws_security_group" "efs_security_group" {

  name        = "efs_security_group"
  description = "Allow access from the web server and Container Service server"
  vpc_id      = var.vpc_id

  ingress {
    description     = "EFS mount target"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = var.ingress_from
  }

  tags = {
    Name = "xnat-efs-sg"
  }

}

# Create the EFS
resource "aws_efs_file_system" "efs" {

  creation_token = local.name
  encrypted      = true

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  lifecycle_policy {
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }

  tags = {
    Name = "xnat-efs"
  }

}

# Add mount targets
resource "aws_efs_mount_target" "mount" {

  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = var.subnet_id
  security_groups = [aws_security_group.efs_security_group.id]

}

# Store the hostname
output "hostname" {
  description = "DNS hostnames of the EFS file system"
  value       = aws_efs_file_system.efs.dns_name
}
