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
    "main"      = "t3.medium"
    "container" = "t2.micro"
  }
}

variable "root_block_device_size" {
  type        = map(any)
  description = "Storage space on the root block device (GB)"
  default = {
    "main"      = 30
    "container" = 10
  }
}

variable "availability_zone" {
  type        = string
  description = "The AZ to use for the EC2 instance"
  default     = "eu-west-2a"
}

variable "subnet_id" {
  type        = string
  description = "The subnet ID to use for the EC2 instance"
}

variable "private_ips" {
  type        = map(string)
  description = "The private IPs to use for the EC2 instances"
}

variable "ssh_key_name" {
  type        = string
  description = "The name of the SSH key to use for the EC2 instance"
}

variable "ssh_cidr" {
  type        = list(string)
  description = "The CIDR blocks to permit SSH access from"
}

variable "http_cidr" {
  type        = list(string)
  description = "The CIDR block to grant HTTP access to the web server"
}

variable "https_cidr" {
  type        = list(string)
  description = "The CIDR block to grant HTTSP access to the web server"
}

variable "db_port" {
  type        = number
  description = "The port to allow connections from the RDS database instance"
}

variable "db_sg_id" {
  type        = string
  description = "The security group ID of the RDS database instance, to allow connections from"
}
