variable "name" {
  type        = string
  description = "The name for the database EC2 instance"
  default     = "xnat-db"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "instance_type" {
  type        = string
  description = "The type of EC2 instance to launch"
  default     = "db.t3.medium"
  validation {
    condition     = startswith(var.instance_type, "db.")
    error_message = "'instance_type' must start with 'db.'"
  }
}

variable "root_block_device_size" {
  type        = string
  description = "Storage space on the root block device (GB)"
  default     = 30
}

variable "availability_zone" {
  type        = string
  description = "The AZ to use for the EC2 instance"
  default     = "eu-west-2a"
}

variable "db_subnet_group_name" {
  type        = string
  description = "The subnet ID to use for the RDS instance"
}

variable "webserver_sg_id" {
  type        = string
  description = "The ID of the security group for the web server. To allow access to the database from the web server only."
}
