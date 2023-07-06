output "webserver_sg_id" {
  value = aws_security_group.sg["main"].id
}

output "xnat_web_hostname" {
  value = aws_instance.servers["main"].public_dns
}

output "xnat_web_public_ip" {
  value = aws_instance.servers["main"].public_ip
}

output "xnat_web_private_ip" {
  value = aws_instance.servers["main"].private_ip
}

output "xnat_cserv_hostname" {
  value = aws_instance.servers["container"].public_dns
}

output "xnat_cserv_public_ip" {
  value = aws_instance.servers["container"].public_ip
}

output "xnat_cserv_private_ip" {
  value = aws_instance.servers["container"].private_ip
}
