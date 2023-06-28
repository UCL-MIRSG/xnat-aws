# General AWS
variable "aws_region" {
  type        = string
  description = "AWS region to use for deploying XNAT"
  default     = "eu-west-2"
}

variable "availability_zone" {
  type        = string
  description = "AZ to use for deploying XNAT"
  default     = "eu-west-2a"
}

# SSH
variable "keypair_name" {
  type        = string
  description = "Name of SSH keypair for logging into the servers"
  default     = "aws-rsa"
}

variable "private_key_filename" {
  type        = string
  description = "Filename in which to store a private key to SSH into the servers"
  default     = "../ssh/aws-rsa.pem"
}

# VPC
variable "cidr_blocks" {
  description = "CIDR block for the VPC and subnets"
  type        = map(any)
  default = {
    "vpc"           = "192.168.0.0/16"  # 192.168.0.0 to 	192.168.255.255
    "public-subnet" = "192.168.56.0/24" # 192.168.56.0 to 192.168.56.255
  }
}

# EC2 private IPs
variable "instance_private_ips" {
  type        = map(any)
  description = "Private IP addresses for each instance"
  default = {
    "xnat_web"   = "192.168.56.10"
    "xnat_db"    = "192.168.56.11"
    "xnat_cserv" = "192.168.56.14"
  }
}

variable "smtp_private_ip" {
  type        = string
  description = "Private IP address to use to the SMTP mail server"
  default     = "192.168.56.101"
}

# EC2 instance types
variable "ec2_instance_types" {
  type        = map(any)
  description = "Instance type to use for each server"
  default = {
    "xnat_web"   = "t2.small"
    "xnat_db"    = "t2.micro"
    "xnat_cserv" = "t2.micro"
  }
}

# EC2 instance OS
variable "instance_os" {
  type        = string
  description = "OS to use for the instance - will determine the AMI to use"
  default     = "centos7"
  validation {
    condition     = contains(["centos7", "rocky8", "rhel9"], var.instance_os)
    error_message = "'instance_os' must be one of ('centos7', 'rocky8', 'rhel9'). ${var.instance_os} is not supported"
  }
}

# Ansible
variable "ansible_ssh_user" {
  description = "Define user to use for connecting to the instance with Ansible based on instance os"
  type        = map(any)
  default = {
    "centos7" = "centos"
    "rocky8"  = "rocky"
    "rhel9"   = "ec2-user"
  }
}
