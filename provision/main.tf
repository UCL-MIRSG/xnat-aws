# Generate SSH key pair
module "ssh_keypair" {
  source   = "./modules/ssh_keygen"
  filename = var.private_key_filename
  name     = var.keypair_name
}

# Launch ec2 instance for the web server
resource "aws_instance" "xnat_web" {
  ami           = data.aws_ami.rhel9.id
  instance_type = var.ec2_instance_type

  availability_zone      = var.availability_zone
  subnet_id              = aws_subnet.xnat-public.id
  vpc_security_group_ids = [aws_security_group.allow-ssh-and-incoming.id]
  key_name               = var.keypair_name

  tags = {
    Name = "xnat_web"
  }
}

# Launch ec2 instance for the database
resource "aws_instance" "xnat_db" {
  ami           = data.aws_ami.rhel9.id
  instance_type = var.ec2_instance_type

  availability_zone      = var.availability_zone
  subnet_id              = aws_subnet.xnat-public.id
  vpc_security_group_ids = [aws_security_group.allow-ssh-only.id]
  key_name               = var.keypair_name

  tags = {
    Name = "xnat_db"
  }
}

output "xnat_web_public_ip" {
  value = aws_instance.xnat_web.public_ip
}

output "xnat_db_public_ip" {
  value = aws_instance.xnat_db.public_ip
}

output "ansible_command" {
  value = "ansible-playbook app.yml -u ec2-user --key-file '../ssh/aws_rsa.pem' -T 300 -i '${aws_instance.xnat_web.public_ip},${aws_instance.xnat_db.public_ip},'"
}
