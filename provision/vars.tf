# General AWS
variable "aws_region" {
  type        = string
  description = "AWS region to use for deploying XNAT"
  default     = "eu-west-2"
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
  default     = "rocky9"
  validation {
    condition     = contains(["rocky8", "rocky9", "rhel9"], var.instance_os)
    error_message = "'instance_os' must be one of ('rocky8', 'rocky9', 'rhel9'). ${var.instance_os} is not supported"
  }
}
