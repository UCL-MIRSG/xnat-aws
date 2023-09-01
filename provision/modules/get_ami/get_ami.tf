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

  owners = ["309956199498"] # RedHat
}

# Get official Rocky 9 AMI for region
data "aws_ami" "rocky9" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Rocky-9-EC2-Base-9.2*.x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["792107900819"] # Rocky, see: https://forums.rockylinux.org/t/rocky-linux-official-aws-ami/3049/25
}

# Get official Rocky 8 AMI for region
data "aws_ami" "rocky8" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Rocky-8-EC2-Base-8.7-20230215.0.x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["792107900819"] # Rocky, see: https://forums.rockylinux.org/t/rocky-linux-official-aws-ami/3049/25
}

output "amis" {
  description = "AMI to use for each OS"
  value = {
    "rocky8" = data.aws_ami.rocky8.id
    "rocky9" = data.aws_ami.rocky9.id
    "rhel9"  = data.aws_ami.rhel9.id
  }
}
