output "vpc_id" {
  value = aws_vpc.xnat.id
  description = "The ID of the VPC"
}

output "public_subnet_id" {
  value = aws_subnet.xnat-public.id
  description = "The ID of the public subnet"
}
