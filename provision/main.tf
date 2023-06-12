# Generate SSH key pair
module "ssh_keypair" {
  source   = "./modules/ssh_keygen"
  filename = var.private_key_filename
}

# Launch ec2 instance for the web server
resource "aws_instance" "xnat_web" {
  ami           = data.aws_ami.rhel9.id
  instance_type = var.ec2_instance_type

  availability_zone      = var.availability_zone
  subnet_id              = aws_subnet.xnat-public.id
  vpc_security_group_ids = [aws_security_group.allow-ssh-and-incoming.id]
  key_name = module.ssh_keypair.name

  tags = {
    Name = "xnat_web"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y"
    ]
  }

  connection {
    type = "ssh"
    user = "ec2-user"
    host = aws_instance.xnat_web.public_ip
    #private_key = tls_private_key.key.private_key_pem
    private_key = module.ssh_keypair.private_key
  }
}

# Launch ec2 instance for the database
resource "aws_instance" "xnat_db" {
  ami           = data.aws_ami.rhel9.id
  instance_type = var.ec2_instance_type

  availability_zone      = var.availability_zone
  subnet_id              = aws_subnet.xnat-public.id
  vpc_security_group_ids = [aws_security_group.allow-ssh-only.id]
  key_name = module.ssh_keypair.name

  tags = {
    Name = "xnat_db"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y"
    ]
  }

  connection {
    type = "ssh"
    user = "ec2-user"
    host = aws_instance.xnat_db.public_ip
    private_key = module.ssh_keypair.private_key
  }
}

output "xnat_web_public_ip" {
  value = aws_instance.xnat_web.public_ip
}

output "xnat_db_public_ip" {
  value = "aws_instance.xnat_db.public_ip"
}

output "ansible_command" {
  value = "ansible-playbook app.yml -u ec2-user --key-file '../ssh/aws_rsa.pem' -T 300 -i '${aws_instance.xnat_web.public_ip},${aws_instance.xnat_db.public_ip},'"
}
