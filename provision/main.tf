terraform {
  required_version = ">=0.15"
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Terraform = "true"
    }
  }
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

  azs             = var.availability_zones
  public_subnets  = var.subnet_cidr_blocks["public"]
  private_subnets = var.subnet_cidr_blocks["private"]

  # Assign public IP address to subnet
  map_public_ip_on_launch = true

  # Don't use any of the default resources
  manage_default_vpc            = false
  manage_default_network_acl    = false
  manage_default_security_group = false
  manage_default_route_table    = false

  public_dedicated_network_acl           = true
  private_dedicated_network_acl          = true
  create_database_subnet_group           = false
  create_database_subnet_route_table     = false
  create_database_internet_gateway_route = false
  enable_nat_gateway                     = false
  enable_vpn_gateway                     = false

  # override default names of the resources
  public_subnet_names  = ["xnat-public"]
  private_subnet_names = ["xnat-private-1", "xnat-private-2"]

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

  root_block_device_size = var.root_block_device_size

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

# Create EFS
module "efs" {
  source    = "./modules/efs"
  vpc_id    = module.setup_vpc.vpc_id
  subnet_id = module.setup_vpc.public_subnets[0]

  # Use concat as module.appstream.sg_id might be an empty list
  ingress_from = concat([module.web_server.webserver_sg_id, module.web_server.cserv_sg_id], module.appstream[*].sg_id)
}

# Launch RDS instances for the database
module "database" {
  source = "./modules/database"

  name              = "xnat_db"
  vpc_id            = module.setup_vpc.vpc_id
  instance_type     = var.ec2_instance_types["xnat_db"]
  availability_zone = var.availability_zones[0]
  subnet_ids        = module.setup_vpc.private_subnets
  webserver_sg_id   = module.web_server.webserver_sg_id
}

# Appstream
module "appstream" {
  source = "github.com/HealthBioscienceIDEAS/terraform-aws-IDEAS-appstream"

  # Use count to create the appstream only if required
  # note that this causes module.appstream to be a list of length 1
  count = var.create_appstream ? 1 : 0

  vpc_id               = module.setup_vpc.vpc_id
  instance_type        = var.as2_instance_type
  desired_instance_num = var.as2_desired_instance_num
  fleet_description    = "IDEAS fleet"
  fleet_name           = "IDEAS-fleet"
  fleet_display_name   = "IDEAS fleet"
  fleet_subnet_ids     = module.setup_vpc.private_subnets
  image_name           = var.as2_image_name
  stack_description    = "IDEAS stack"
  stack_display_name   = "IDEAS stack"
  stack_name           = "IDEAS-stack"
}

# Security group rule to allow outgoing traffic from AppStream
resource "aws_security_group_rule" "appstream_allow_all_outgoing" {
  count = var.create_appstream ? 1 : 0

  type              = "egress"
  security_group_id = module.appstream[0].sg_id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
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
    xnat_cserv_private_ip = module.web_server.xnat_cserv_private_ip,
    efs_hostname          = module.efs.hostname,
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
