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
