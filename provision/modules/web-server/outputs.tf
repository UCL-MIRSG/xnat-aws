output "sg_id" {
  value = aws_security_group.sg.id
}

output "hostname" {
  value = aws_instance.xnat_web.public_dns
}

output "public_ip" {
  value = aws_instance.xnat_web.public_ip
}

output "private_ip" {
  value = aws_instance.xnat_web.private_ip
}
