# VPC variables
variable "cidr_blocks" {
  description = "CIDR block for the VPC and subnets"
  type        = map(any)
  default = {
    "vpc"           = "192.168.0.0/16"  # 192.168.0.0 to 	192.168.255.255
    "public-subnet" = "192.168.56.0/24" # 192.168.56.0 to 192.168.56.255
  }
}

variable "availability_zone" {
  type        = string
  description = "AZ to use for deploying XNAT"
  default     = "eu-west-2a"
}
