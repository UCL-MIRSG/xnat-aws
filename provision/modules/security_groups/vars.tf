variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "public_cidr" {
  type        = list(string)
  description = "The CIDR blcok for allowing ssh access from the public subnet"
}
