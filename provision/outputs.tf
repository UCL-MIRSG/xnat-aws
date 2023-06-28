output "ansible_install_dependencies" {
  description = "Run this command from the `xnat-aws/configure` directory to install the required Ansible dependencies."
  value       = "ansible-galaxy install -r playbooks/roles/requirements.yml --force"
}

output "ansible_install_cserv" {
  description = "Run this command from the `xnat-aws/configure` directory to install the Container Service."
  value       = "ansible-playbook playbooks/install_container_service.yml -i hosts.yml --vault-password-file=.vault_password"
}

output "ansible_install_xnat" {
  description = "Run this command from the `xnat-aws/configure` directory to install and configure XNAT."
  value       = "ansible-playbook playbooks/install_xnat.yml -i hosts.yml --vault-password-file=.vault_password"
}

output "ansible_view_vault" {
  description = "Run this command from the `xnat-aws/configure` directory to view passwords in the Ansible vault."
  value       = "ansible-vault view group_vars/all/vault --vault-password .vault_password"
}

output "xnat_web_url" {
  description = "Once XNAT has been installed and configured, the web server will be accessible at this URL."
  value       = "http://${aws_instance.xnat_web.public_dns}"
}
