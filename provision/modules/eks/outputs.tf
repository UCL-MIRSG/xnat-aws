output "cluster_id" {
  value = aws_eks_cluster.cluster.id
}

output "sg_id" {
  value = aws_security_group.sg.id
}

output "endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

output "ca_cert" {
  value = base64decode(aws_eks_cluster.cluster.certificate_authority[0].data)
}
