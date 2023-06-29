locals {

  # AWS
  ssh_key_name             = "aws-rsa"
  ssh_private_key_filename = "../ssh/aws-rsa"
  ssh_public_key_filename  = "../ssh/aws-rsa.pub"

  # Ansible user for connecting to the instance 
  ansible_ssh_user = {
    "centos7" = "centos"
    "rocky8"  = "rocky"
    "rhel9"   = "ec2-user"
  }

}
