variable "webserver_name" {
  type        = string
  description = "The name of the web server"
  default = "xnat-web"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "ami" {
  type        = string
  description = "The AMI to use for the EC2 instance"
}

variable "instance_type" {
  type        = string
  description = "The instance type to use for the EC2 instance"
}

variable "availability_zone" {
  type        = string
  description = "The AZ to use for the EC2 instance"
}

variable "subnet_id" {
  type        = string
  description = "The subnet ID to use for the EC2 instance"
}

variable "private_ip" {
  type        = string
  description = "The private IP to use for the EC2 instance"
}

variable "ssh_key_name" {
  type        = string
  description = "The name of the SSH key to use for the EC2 instance"
}

variable "public_cidr" {
  type        = list(string)
  description = "The CIDR blcok for allowing ssh access from the public subnet"
}
