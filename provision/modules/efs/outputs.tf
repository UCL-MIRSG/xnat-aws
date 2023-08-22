# Store the hostname
output "hostname" {
  description = "DNS hostnames of the EFS file system"
  value       = aws_efs_file_system.efs.dns_name
}

output "id" {
  description = "The ID that identifies the file system (e.g., `fs-ccfc0d65`)"
  value       = aws_efs_file_system.efs.id
}
