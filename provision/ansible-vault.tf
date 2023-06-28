# Generate passwords for the vault and its encryption
resource "random_password" "vault" {
  for_each         = toset(local.passwords)
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Write the encryption password to file
resource "local_sensitive_file" "ansible-vault-password" {
  content         = random_password.vault["encryption"].result
  filename        = local.encryption_password_file
  file_permission = "0644"
}


# Write the passwords to file and encrypt the vault
resource "local_sensitive_file" "ansible-vault" {

  content = templatefile("templates/ansible_vault.tftpl", {
    ldap_password          = random_password.vault["ldap"].result,
    postgres_xnat_password = random_password.vault["postgres_xnat"].result,
    admin_password         = random_password.vault["admin"].result,
    service_admin_password = random_password.vault["service_admin"].result,
    smtp_password          = random_password.vault["smtp"].result,
  })
  filename        = local.ansible_vault_file
  file_permission = "0644"

  provisioner "local-exec" {
    command = "ansible-vault encrypt ${local.ansible_vault_file} --vault-password ${local.encryption_password_file}"
  }

}

