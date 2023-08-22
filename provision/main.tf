terraform {
  required_version = ">=0.15"
}

provider "aws" {
  region = var.aws_region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
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
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

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

  # Must be enabled to use EFS with EKS
  # Otherwise the CSI driver will fail to resolve the EFS endpoint
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_dedicated_network_acl           = true
  private_dedicated_network_acl          = true
  create_database_subnet_group           = false
  create_database_subnet_route_table     = false
  create_database_internet_gateway_route = false
  enable_nat_gateway                     = true
  single_nat_gateway                     = true
  one_nat_gateway_per_az                 = false
  enable_vpn_gateway                     = false

  # override default names of the resources
  public_subnet_names  = ["xnat-public-1", "xnat-public-2"]
  private_subnet_names = ["xnat-private-1", "xnat-private-2"]

  default_security_group_name = "default-xnat-sg"
  default_vpc_name            = "default-xnat-vpc"
  default_network_acl_name    = "default-xnat-acl"
  default_route_table_name    = "default-xnat-route-table"

  public_subnet_tags = {
    "kubernetes.io/roles/elb"                   = 1
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/roles/internal-elb"          = 1
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }

  # these tags will be applied to all resources
  tags = {
    Name = "xnat"
  }

}

# Launch ec2 instances for the web server
module "web_server" {
  source = "./modules/web-server"

  instance_type          = var.ec2_instance_types["xnat_web"]
  root_block_device_size = var.root_block_device_size

  vpc_id            = module.setup_vpc.vpc_id
  ami               = module.get_ami.amis[var.instance_os]
  availability_zone = var.availability_zones[0]
  subnet_id         = module.setup_vpc.public_subnets[0]
  private_ip        = var.instance_private_ips["xnat_web"]
  ssh_key_name      = local.ssh_key_name
  ssh_cidr          = concat([module.get_my_ip.my_public_cidr], var.extend_ssh_cidr)
  http_cidr         = concat([module.get_my_ip.my_public_cidr], var.extend_http_cidr)
  https_cidr        = concat([module.get_my_ip.my_public_cidr], var.extend_https_cidr)
}

# Set up EKS for running the Container Service
module "eks" {
  source = "./modules/eks"

  cluster_name       = var.eks_cluster_name
  vpc_id             = module.setup_vpc.vpc_id
  availability_zones = var.availability_zones
  subnet_ids      = concat([module.setup_vpc.public_subnets, module.setup_vpc.private_subnets])
  ssh_key_name    = local.ssh_key_name
  ssh_cidr        = concat([module.get_my_ip.my_public_cidr], var.extend_ssh_cidr)
  webserver_sg_id = module.web_server.sg_id

}

# Update our kube config
resource "null_resource" "kupdate-kubeconfig" {
  depends_on = [module.eks]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name demo --region ${var.aws_region}"
  }
}

module "fargate" {
  source = "./modules/fargate"

  cluster_name = var.eks_cluster_name
  namespace    = var.eks_cluster_name
  subnet_ids   = module.setup_vpc.private_subnets

}

# Patch kubernetes
data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
}

resource "null_resource" "k8s_patcher" {
  depends_on = [module.fargate]

  triggers = {
    endpoint = module.eks.endpoint
    ca_crt   = module.eks.ca_cert
    token    = data.aws_eks_cluster_auth.eks.token
  }

  provisioner "local-exec" {
    command = <<EOH
cat >/tmp/ca.crt <<EOF
${module.eks.ca_cert}
EOF
kubectl \
  --server="${module.eks.endpoint}" \
  --certificate_authority=/tmp/ca.crt \
  --token="${data.aws_eks_cluster_auth.eks.token}" \
  patch deployment coredns \
  -n kube-system --type json \
  -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'
EOH
  }

  lifecycle {
    ignore_changes = [triggers]
  }
}



# Create EFS
module "efs" {
  source       = "./modules/efs"
  vpc_id       = module.setup_vpc.vpc_id
  subnet_id    = module.setup_vpc.public_subnets[0]
  ingress_from = [module.web_server.sg_id]  # TODO: all ingress from EKS / fargate
}

# Launch RDS instances for the database
module "database" {
  source = "./modules/database"

  name              = "xnat_db"
  vpc_id            = module.setup_vpc.vpc_id
  instance_type     = var.ec2_instance_types["xnat_db"]
  availability_zone = var.availability_zones[0]
  subnet_ids        = module.setup_vpc.private_subnets
  webserver_sg_id   = module.web_server.sg_id
}

# Copy public key to AWS
resource "aws_key_pair" "key_pair" {
  key_name   = local.ssh_key_name
  public_key = file(local.ssh_public_key_filename)
}

# Write the ansible hosts file
resource "local_file" "ansible-hosts" {
  content = templatefile("templates/ansible_hosts.yml.tftpl", {
    ssh_key_filename    = local.ssh_private_key_filename,
    ssh_user            = local.ansible_ssh_user[var.instance_os],
    xnat_web_hostname   = module.web_server.hostname,
    xnat_web_public_ip  = module.web_server.public_ip,
    xnat_web_private_ip = module.web_server.private_ip,
    xnat_web_smtp_ip    = var.smtp_private_ip,
    xnat_db_hostname    = module.database.xnat_db_hostname,
    xnat_db_username    = module.database.xnat_db_username,
    xnat_db_port        = module.database.xnat_db_port,
    xnat_db_name        = module.database.xnat_db_name,
    efs_hostname        = module.efs.hostname,
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
