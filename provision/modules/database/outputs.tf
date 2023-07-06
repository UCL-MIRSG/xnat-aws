output "xnat_db_hostname" {
  description = "RDS instance hostname"
  value = aws_db_instance.db.address
  sensitive = true
}

output "xnat_db_port" {
  description = "RDS instance port"
  value = aws_db_instance.db.port
  sensitive = true
}

output "xnat_db_username" {
  description = "RDS instance root username"
  value = aws_db_instance.db.username
  sensitive = true
}
