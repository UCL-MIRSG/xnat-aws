output "ansible_view_vault" {
  description = "Run this command from the `xnat-aws/configure` directory to view passwords in the Ansible vault."
  value       = "ansible-vault view group_vars/all/vault --vault-password .vault_password"
}
