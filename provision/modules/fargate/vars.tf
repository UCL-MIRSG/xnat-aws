variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "namespace" {
  type        = string
  description = "Kubernetes namespace to be managed"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The subnet IDs use for Fargate"
}
