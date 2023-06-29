locals {

  # AWS
  ssh_private_key_filename = "../ssh/aws-rsa"
  ssh_public_key_filename  = "../ssh/aws-rsa.pub"

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
