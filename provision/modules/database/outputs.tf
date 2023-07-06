output "xnat_db_hostname" {
  value = aws_instance.db.public_dns
}

output "xnat_db_public_ip" {
  value = aws_instance.db.public_ip
}

output "xnat_db_private_ip" {
  value = aws_instance.db.private_ip
}
