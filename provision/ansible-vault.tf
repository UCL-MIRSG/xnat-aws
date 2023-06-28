# Generate a password to encrypt the vault
resource "random_password" "encryption_password" {
  length = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Write the encryption password to file
resource = "local_sensitive_file" "ansible-vault-password" {
  content = random_password.encryption_password.result
  filename = ../configure/.vault_password
  file_permission = "0644"
}

# Generate passwords for the vault
resource "random_password" "vault_passwords" {
  for_each         = toset(local.passwords)
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Write the passwords to file and encrypt the vault
resource "local_sensitive_file" "ansible-vault" {

content = templatefile("templates/ansible_vault.tftpl", {
    one   = random_password.passwords["one"].result,
    two   = random_password.passwords["two"].result,
    three = random_password.passwords["three"].result,
  })
  filename        = "../configure/group_vars/all/vault"
  file_permission = "0644"

  provisioner "local-exec" {
    command = "ansible-vault encrypt ../configure/group_vars/all/vault --vault-password ../configure/.vault_password
  }

}

