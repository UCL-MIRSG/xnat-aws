# list of passwords to generate for the Ansible vault
locals {

  # Ansible vault
  ansible_vault_file       = "../configure/group_vars/all/vault"
  encryption_password_file = "../configure/.vault_password"
  passwords = [
    "encryption",
    "ldap",
    "postgres_xnat",
    "admin",
    "service_admin",
    "smtp"
  ]

}
