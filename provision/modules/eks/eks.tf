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

resource "aws_iam_role" "eks-cluster" {
  name = "eks-cluster-${var.cluster_name}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "amazon-eks-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster.name
}

resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.eks-cluster.arn

  vpc_config {

    endpoint_private_access = false
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"] # todo: do we need public access?
    subnet_ids              = var.subnet_ids
  }

  depends_on = [aws_iam_role_policy_attachment.amazon-eks-cluster-policy]
}
