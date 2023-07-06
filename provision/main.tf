terraform {
  required_version = ">=0.15"
}

provider "aws" {
  region = var.aws_region
}

# Get IP address for this machine
module "get_my_ip" {
  source = "./modules/get_my_ip"
}

# Determine which AMI to use
module "get_ami" {
  source = "./modules/get_ami"
}

# Set up the VPC
module "setup_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "xnat-vpc"
  cidr = var.vpc_cidr_block

  azs                     = var.availability_zones
  private_subnets         = var.subnet_cidr_blocks["private"]
  public_subnets          = var.subnet_cidr_blocks["public"]
  map_public_ip_on_launch = true # Assign public IP address to subnet

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  tags = {
    Terraform = "true"
    Name      = "VPC for XNAT"
  }
}

# Launch ec2 instances for the web server (main + container)
module "web_server" {
  source = "./modules/web-server"

  names = {
    "main"      = "xnat_web"
    "container" = "xnat_cserv"
  }

  instance_types = {
    "main"      = var.ec2_instance_types["xnat_web"]
    "container" = var.ec2_instance_types["xnat_cserv"]
  }
  root_block_device_size = {
    "main"      = var.root_block_device_size["xnat_web"]
    "container" = var.root_block_device_size["xnat_cserv"]
  }

  vpc_id            = module.setup_vpc.vpc_id
  ami               = module.get_ami.amis[var.instance_os]
  availability_zone = var.availability_zones[0]
  subnet_id         = module.setup_vpc.public_subnets[0]
  private_ips       = var.instance_private_ips
  ssh_key_name      = local.ssh_key_name
  ssh_cidr          = concat([module.get_my_ip.my_public_cidr], var.extend_ssh_cidr)
  http_cidr         = concat([module.get_my_ip.my_public_cidr], var.extend_http_cidr)
  https_cidr        = concat([module.get_my_ip.my_public_cidr], var.extend_https_cidr)
}

module "database" {
  source = "./modules/database"

  name                   = "xnat_db"
  vpc_id                 = module.setup_vpc.vpc_id
  ami                    = module.get_ami.amis[var.instance_os]
  instance_type          = var.ec2_instance_types["xnat_db"]
  availability_zone      = var.availability_zones[0]
  subnet_id              = module.setup_vpc.private_subnets[0]
  private_ip             = var.db_private_ip
  webserver_sg_id        = module.web_server.webserver_sg_id
}

# Copy public key to AWS
resource "aws_key_pair" "key_pair" {
  key_name   = local.ssh_key_name
  public_key = file(local.ssh_public_key_filename)
}

# Write the ansible hosts file
resource "local_file" "ansible-hosts" {
  content = templatefile("templates/ansible_hosts.yml.tftpl", {
    ssh_key_filename      = local.ssh_private_key_filename,
    ssh_user              = local.ansible_ssh_user[var.instance_os],
    xnat_web_hostname     = module.web_server.xnat_web_hostname,
    xnat_web_public_ip    = module.web_server.xnat_web_public_ip,
    xnat_web_private_ip   = module.web_server.xnat_web_private_ip,
    xnat_web_smtp_ip      = var.smtp_private_ip,
    xnat_db_hostname      = module.database.xnat_db_hostname,
    xnat_db_username      = module.database.xnat_db_username,
    xnat_cserv_hostname   = module.web_server.xnat_cserv_hostname,
    xnat_cserv_public_ip  = module.web_server.xnat_cserv_public_ip,
    xnat_cserv_private_ip = module.web_server.xnat_cserv_private_ip
  })
  filename        = "../configure/hosts.yml"
  file_permission = "0644"
}

locals {
  # AWS
  ssh_key_name             = "aws-rsa"
  ssh_private_key_filename = "../ssh/aws-rsa"
  ssh_public_key_filename  = "../ssh/aws-rsa.pub"

  # Ansible user for connecting to the instance
  ansible_ssh_user = {
    "rocky8" = "rocky"
    "rocky9" = "rocky"
    "rhel9"  = "ec2-user"
  }
}
