# Generate and save keypair for SSH into instances
resource "tls_private_key" "key" {
  algorithm = "RSA"
}

resource "local_file" "private_key" {
  filename          = local.ssh_key_filename
  sensitive_content = tls_private_key.key.private_key_openssh
  file_permission   = "0600"
}

resource "local_file" "public_key" {
  filename          = "${local.ssh_key_filename}.pub"
  sensitive_content = tls_private_key.key.public_key_openssh
  file_permission   = "0644"
}

