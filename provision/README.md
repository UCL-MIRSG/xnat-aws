# Create infrastructure on AWS using Terraform

The Terraform scripts will create the following:

- a Virtual Private Cloud (VPC) and security groups
- two EC2 instances - `xnat_web` and `xnat_db` for the webserver and database, respectively
- attach an Elastic Block Storage (EBS) volume to `xnat_db`

## Warning

A single, **public** subnet is created in the VPC. This means that the instances will have public IP addresses and may be vulnerable to attack. However, when configuring the instances with Ansible, a firewall will be created (using `firewalld`) to limit connections to the instances.

## Usage

To create the infrastructure on AWS:

```bash
terraform init
terraform plan
teraform apply
```

## Output

After running `terraform apply`, a command will be printed for configuration the infrastructure with Ansible. It will look something like this:

```bash
ansible-playbook app.yml -u ec2-user --key-file '../ssh/aws_rsa.pem' -T 300 -i '18.135.96.91,'
```

To destroy the infrastructure:

```bash
terraform destroy
```
