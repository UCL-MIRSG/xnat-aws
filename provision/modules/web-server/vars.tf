variable "names" {
  type        = map(string)
  description = "The names for the EC2 instances"
  default = {
    "main"      = "xnat_web"
    "container" = "xnat_cserv"
  }
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "ami" {
  type        = string
  description = "The AMI to use for the EC2 instance"
}

variable "instance_types" {
  type        = map(string)
  description = "The instance type to use for the EC2 instances"
  default = {
    "main"      = "t2.small"
    "container" = "t2.micro"
  }
}

variable "availability_zone" {
  type        = string
  description = "The AZ to use for the EC2 instance"
}

variable "subnet_id" {
  type        = string
  description = "The subnet ID to use for the EC2 instance"
}

variable "private_ips" {
  type        = map(string)
  description = "The private IPs to use for the EC2 instances"
  default = {
    "main"      = "192.168.56.10"
    "container" = "192.168.56.14"
  }
}

variable "ssh_key_name" {
  type        = string
  description = "The name of the SSH key to use for the EC2 instance"
}

variable "public_cidr" {
  type        = list(string)
  description = "The CIDR block for allowing ssh access from the public subnet"
}
