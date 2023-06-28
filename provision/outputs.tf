output "ansible_view_vault" {
  description = "Run this command from the `xnat-aws/configure` directory to view passwords in the Ansible vault."
  value       = "ansible-vault view group_vars/all/vault --vault-password .vault_password"
}

output "xnat_web_url" {
  description = "Once XNAT has been installed and configured, the web server will be accessible at this URL."
  value       = "http://${aws_instance.xnat_web.public_dns}"
}
