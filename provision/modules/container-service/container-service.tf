locals {
  name            = "xnat_cserv"
  cluster_version = "1.27"
  ssh_port        = 22
  container_port  = 2376
  any_port        = 0
  tcp_protocol    = "tcp"
  any_protocol    = "-1"
  all_ips         = ["0.0.0.0/0"]
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

data "aws_ami" "eks_default" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${local.cluster_version}-v*"]
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name    = local.name
  cluster_version = local.cluster_version

  create_cluster_security_group = false
  cluster_security_group_id     = aws_security_group.sg.id

  # TODO: put the control plane in an intra subnet and worker nodes in private subnets
  cluster_ip_family        = "ipv4"
  vpc_id                   = var.vpc_id
  control_plane_subnet_ids = var.subnet_ids # where control plane is deployed
  subnet_ids               = var.subnet_ids # where nodes are deployed

  cluster_endpoint_public_access = true
  # TODO: only allow access from the web server
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["t3.large", "c7g.xlarge"]

    # We are using the IRSA created below for permissions
    # However, we have to deploy with the policy attached FIRST (when creating a fresh cluster)
    # and then turn this off after the cluster/node group is created. Without this initial policy,
    # the VPC CNI fails to assign IPs and nodes cannot join the cluster
    # See https://github.com/aws/containers-roadmap/issues/1666 for more context
    #iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {

    container_service = {
      name            = "cserv-node-group-1"
      use_name_prefix = true

      subnet_ids = var.subnet_ids # where nodes are deployed

      min_size     = 0
      max_size     = 6
      desired_size = 0

      ami_id               = data.aws_ami.eks_default.image_id
      capacity_type        = "SPOT"
      force_update_version = true

      description = "EKS managed node group for running the Container Service"

      ebs_optimized           = true
      disable_api_termination = false
      enable_monitoring       = false

      create_iam_role          = true
      iam_role_name            = "eks-managed-node-group-complete-example"
      iam_role_use_name_prefix = false
      iam_role_description     = "EKS managed node group complete example role"
      iam_role_tags = {
        Purpose = "XNAT Container Service"
      }
      iam_role_additional_policies = {
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
        # additional                         = aws_iam_policy.node_additional.arn
      }

      tags = {
        Name        = "xnat-cserv-eks-node-group"
        Description = "EKS managed node group for running the Container Service "
      }
    }

  }

}

# Security groups
resource "aws_security_group" "sg" {
  name        = "${local.name}-sg"
  vpc_id      = var.vpc_id
  description = "Security group for the ${local.name} server"

  tags = {
    Name = local.name
  }
}


# Security group rules ------------------------------------------------------------------------
resource "aws_security_group_rule" "allow_ssh_incoming" {
  type              = "ingress"
  security_group_id = aws_security_group.sg.id

  from_port   = local.ssh_port
  to_port     = local.ssh_port
  protocol    = local.tcp_protocol
  cidr_blocks = var.ssh_cidr
}

resource "aws_security_group_rule" "allow_all_outgoing" {
  type              = "egress"
  security_group_id = aws_security_group.sg.id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_container_incoming" {
  type              = "ingress"
  security_group_id = aws_security_group.sg.id

  from_port                = local.container_port
  to_port                  = local.container_port
  protocol                 = local.tcp_protocol
  source_security_group_id = var.webserver_sg_id # only allow connection from web server
}


