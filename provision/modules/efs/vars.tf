variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to create the EFS volume in"
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet to mount the volume in"
}

variable "ingress_from" {
  type        = list(string)
  description = "The CIDR blocks to allow access to the EFS store"
}


