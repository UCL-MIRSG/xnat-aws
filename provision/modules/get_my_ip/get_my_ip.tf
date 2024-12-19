# Get the public IP address for this machine
data "http" "icanhazip" {
  url = "https://ipv4.icanhazip.com"
}

output "my_public_cidr" {
  value = "${chomp(data.http.icanhazip.response_body)}/32"
}
