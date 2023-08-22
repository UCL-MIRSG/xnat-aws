variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "availability_zones" {
  type        = list(string)
  description = "The AZs to use for the EKS"
  default     = ["eu-west-2a"]
}

variable "subnet_ids" {
  type        = list(string)
  description = "The subnet IDs use for EKS"
}

variable "ssh_key_name" {
  type        = string
  description = "The name of the SSH key to use for EKS"
}

variable "ssh_cidr" {
  type        = list(string)
  description = "The CIDR blocks to permit SSH access from"
}

variable "webserver_sg_id" {
  type        = string
  description = "The ID of the security group for the web server. To allow access to the control plane from the web server only."
}
