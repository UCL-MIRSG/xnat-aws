# General AWS
variable "aws_region" {
  type        = string
  description = "AWS region to use for deploying XNAT"
  default     = "eu-west-2"
}

variable "availability_zones" {
  type        = list(string)
  description = "AZs to use for deploying XNAT"
  default     = ["eu-west-2a", "eu-west-2b"]
}

variable "deployment_env_name" {
  type = string
  description = "Name for the deployment environment to distinguish it from other deployments"
  default = "xnat"
}

# VPC
variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "192.168.0.0/16" # 192.168.0.0 to 	192.168.255.255
}

variable "subnet_cidr_blocks" {
  description = "CIDR block for the VPC and subnets"
  type        = map(any)
  default = {
    "public"  = ["192.168.56.0/24"] # 192.168.56.0 to 192.168.56.255
    "private" = ["192.168.100.0/24", "192.168.101.0/24"]
  }
}

# EC2 private IPs
variable "instance_private_ips" {
  type        = map(any)
  description = "Private IP addresses for each instance"
  default = {
    "xnat_web"   = "192.168.56.10"
    "xnat_cserv" = "192.168.56.14"
  }
}

variable "smtp_private_ip" {
  type        = string
  description = "Private IP address to use to the SMTP mail server"
  default     = "192.168.56.101"
}

# CIDR blocks to add to whitelist (in addition to your own IP)
variable "extend_ssh_cidr" {
  type        = list(string)
  description = "CIDR blocks servers should permit SHH access from, in addition to your own IP address"
  default     = []
}

variable "extend_http_cidr" {
  type        = list(string)
  description = "The CIDR blocks to grant HTTP access to the web server, in addition to your own IP address"
  default     = []
}

variable "extend_https_cidr" {
  type        = list(string)
  description = "The CIDR blocks to grant HTTSP access to the web server, in addition to your own IP address"
  default     = []
}

# EC2 instance types
variable "ec2_instance_types" {
  type        = map(any)
  description = "Instance type to use for each server"
  default = {
    "xnat_web"   = "t3.large"
    "xnat_db"    = "db.t3.large"
    "xnat_cserv" = "m4.xlarge"
  }
}

# EC2 root block device volume size
variable "root_block_device_size" {
  type        = number
  description = "Storage space on the root block device (GB)"
  default     = 30
}

# EC2 instance OS
variable "instance_os" {
  type        = string
  description = "OS to use for the instance - will determine the AMI to use"
  default     = "rocky9"
  validation {
    condition     = contains(["rocky8", "rocky9", "rhel9"], var.instance_os)
    error_message = "'instance_os' must be one of ('rocky8', 'rocky9', 'rhel9'). ${var.instance_os} is not supported"
  }
}

# Create AppStream image?
variable "create_appstream" {
  type        = bool
  description = "Whether to create an AppStream image"
}

variable "as2_instance_type" {
  type        = string
  description = "Instance type to use for the AppStream image"
  default     = "stream.standard.medium"
}

variable "as2_desired_instance_num" {
  type        = number
  description = "Number of instances to use for the AppStream image"
  default     = 1
}

variable "as2_image_name" {
  type        = string
  description = "Name of the AppStream image"
  default     = "IDEAS-FSL-AmazonLinux2-EFSMount-2023-08-30"
}
