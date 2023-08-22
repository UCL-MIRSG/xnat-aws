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

variable "availability_zone" {
  type        = string
  description = "The AZ to use for the EC2 instance"
  default     = "eu-west-2a"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet ids to deploy RDS instances in"
}

variable "webserver_sg_id" {
  type        = string
  description = "The ID of the security group for the web server. To allow access to the database from the web server only."
}
