resource "random_password" "passwords" {i
  for_each         = toset(local.passwords)
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "local_sensitive_file" "ansible-vault" {
  content = templatefile("templates/ansible_vault.tftpl", {
    one   = random_password.passwords["one"].result,
    two   = random_password.passwords["two"].result,
    three = random_password.passwords["three"].result,
  })
  filename        = "../configure/group_vars/all/vault"
  file_permission = "0644"
}



