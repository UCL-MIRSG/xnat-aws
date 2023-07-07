variable "name" {
  type        = string
  description = "The name for the database EC2 instance"
  default     = "xnat_db"
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
  description = "The type of EC2 instance to launch"
  default     = "t3.medium"
}

variable "private_ip" {
  type        = string
  description = "The private IP to use for the database EC2 instance"
  default     = "192.168.56.11"
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

variable "ssh_key_name" {
  type        = string
  description = "The name of the SSH key to use for the EC2 instance"
}

variable "ssh_cidr" {
  type        = list(string)
  description = "The CIDR block for allowing ssh access from the public subnet"
}

variable "webserver_sg_id" {
  type        = string
  description = "The ID of the security group for the web server. To allow access to the database from the web server only."
}
