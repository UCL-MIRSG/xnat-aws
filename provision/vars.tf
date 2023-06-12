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
variable "private_key_filename" {
  type        = string
  description = "Filename in which to store a private key to SSH into the servers"
}

# EC2 instance
variable "ec2_instance_type" {
  type        = string
  description = "EC2 instance type to use for xnat_web and xnat_db servers"
  default     = "t2.micro"
}
