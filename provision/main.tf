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

# Launch ec2 instance for the web server
resource "aws_instance" "xnat_web" {
  ami           = data.aws_ami.centos7.id
  instance_type = var.ec2_instance_type

  availability_zone      = var.availability_zone
  subnet_id              = aws_subnet.xnat-public.id
  private_ip             = "192.168.56.10"
  vpc_security_group_ids = [aws_security_group.xnat-web.id]
  key_name               = var.keypair_name

  tags = {
    Name = "xnat_web"
  }
}

# Launch ec2 instance for the bastion
resource "aws_instance" "xnat_bastion" {
  ami           = data.aws_ami.centos7.id
  instance_type = var.ec2_instance_type

  availability_zone      = var.availability_zone
  subnet_id              = aws_subnet.xnat-public.id
  private_ip             = "192.168.56.11"
  vpc_security_group_ids = [aws_security_group.bastion.id]
  key_name               = var.keypair_name

  tags = {
    Name = "xnat_bastion"
  }
}

# Launch ec2 instance for the database
resource "aws_instance" "xnat_db" {
  ami           = data.aws_ami.centos7.id
  instance_type = var.ec2_instance_type

  availability_zone = var.availability_zone
  subnet_id         = aws_subnet.xnat-private.id
  private_ip             = "192.168.57.11"
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
    xnat_web_hostname   = aws_instance.xnat_web.public_dns,
    xnat_web_public_ip  = aws_instance.xnat_web.public_ip,
    xnat_web_private_ip = aws_instance.xnat_web.private_ip,
    xnat_web_smtp_ip = "192.168.56.101",
    xnat_db_hostname = aws_instance.xnat_db.private_ip,
    xnat_bastion_public_ip = aws_instance.xnat_bastion.public_ip,
  })
  filename        = "../configure/hosts.yml"
  file_permission = "0644"
}

output "ansible_command" {
  value = "ansible-playbook playbooks/install_xnat.yml -i hosts.yml --vault-password-file=.vault_password
}
