# Get IP address for this machine
module "get_my_ip" {
  source = "./modules/get_my_ip"
}

# Generate SSH key pair
module "ssh_keypair" {
  source   = "./modules/ssh_keygen"
  filename = var.private_key_filename
  name     = var.keypair_name
}

# Determine which AMI to use
module "get_ami" {
  source = "./modules/get_ami"
}

# Launch ec2 instance for the web server
resource "aws_instance" "xnat_web" {
  #ami           = data.aws_ami.centos7.id
  ami           = module.get_ami.amis[var.instance_os]
  instance_type = var.ec2_instance_types["xnat_web"]

  availability_zone      = var.availability_zone
  subnet_id              = aws_subnet.xnat-public.id
  private_ip             = var.instance_private_ips["xnat_web"]
  vpc_security_group_ids = [aws_security_group.xnat-web.id]
  key_name               = var.keypair_name

  tags = {
    Name = "xnat_web"
  }
}

# Launch ec2 instance for the database
resource "aws_instance" "xnat_db" {
  #ami           = data.aws_ami.centos7.id
  ami           = module.get_ami.amis[var.instance_os]
  instance_type = var.ec2_instance_types["xnat_db"]

  availability_zone      = var.availability_zone
  subnet_id              = aws_subnet.xnat-public.id
  private_ip             = var.instance_private_ips["xnat_db"]
  vpc_security_group_ids = [aws_security_group.xnat-db.id]
  key_name               = var.keypair_name

  tags = {
    Name = "xnat_db"
  }
}

# Write the ansible hosts file
resource "local_file" "ansible-hosts" {
  content = templatefile("templates/ansible_hosts.yml.tftpl", {
    ssh_key_filename    = var.private_key_filename,
    ssh_user            = var.ansible_ssh_user[var.instance_os],
    xnat_web_hostname   = aws_instance.xnat_web.public_dns,
    xnat_web_public_ip  = aws_instance.xnat_web.public_ip,
    xnat_web_private_ip = aws_instance.xnat_web.private_ip,
    xnat_web_smtp_ip    = var.smtp_private_ip,
    xnat_db_hostname    = aws_instance.xnat_db.public_dns,
    xnat_db_public_ip   = aws_instance.xnat_db.public_ip,
    xnat_db_private_ip  = aws_instance.xnat_db.private_ip,
  })
  filename        = "../configure/hosts.yml"
  file_permission = "0644"
}

output "ansible_command" {
  value = "ansible-playbook playbooks/install_xnat.yml -i hosts.yml --vault-password-file=.vault_password"
}
