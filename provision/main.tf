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

  # NOTE: database subnets only without private subnets doesn't work
  # cfr. https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/944
  azs              = var.availability_zones
  public_subnets   = var.subnet_cidr_blocks["public"]
  private_subnets  = var.subnet_cidr_blocks["private"]
  database_subnets = var.subnet_cidr_blocks["database"]

  # Assign public IP address to subnet
  map_public_ip_on_launch = true

  # Don't use any of the default resources
  manage_default_vpc            = false
  manage_default_network_acl    = false
  manage_default_security_group = false
  manage_default_route_table    = false

  public_dedicated_network_acl  = true
  private_dedicated_network_acl = true
  create_database_subnet_group  = true
  enable_nat_gateway            = false
  enable_vpn_gateway            = false

  # override default names of the resources
  public_subnet_names        = ["xnat-public"]
  private_subnet_names       = ["xnat-private-1", "xnat-private-2"]
  database_subnet_names      = ["xnat-db-1", "xnat-db-2"]
  database_subnet_group_name = "xnat-db"

  default_security_group_name = "default-xnat-sg"
  default_vpc_name            = "default-xnat-vpc"
  default_network_acl_name    = "default-xnat-acl"
  default_route_table_name    = "default-xnat-route-table"

  # these tags will be applied to all resources
  tags = {
    Name = "xnat"
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

  name                 = "xnat_db"
  vpc_id               = module.setup_vpc.vpc_id
  instance_type        = var.ec2_instance_types["xnat_db"]
  availability_zone    = var.availability_zones[0]
  db_subnet_group_name = module.setup_vpc.database_subnet_group_name
  webserver_sg_id      = module.web_server.webserver_sg_id
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
    xnat_db_port          = module.database.xnat_db_port,
    xnat_db_name          = module.database.xnat_db_name,
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
