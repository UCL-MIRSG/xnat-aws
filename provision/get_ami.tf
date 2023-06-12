# Get official RHEL9 AMI for region
data "aws_ami" "rhel9" {
  most_recent = true

  filter {
    name   = "name"
    values = ["RHEL-9.2.0_HVM-*x86_64*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["309956199498"]
}
