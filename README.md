# xnat-aws
Deploy XNAT on AWS using Terraform and Ansible.

Terraform is used to create the infrastructure on AWS and Ansible is then used to configure the instances for XNAT deployment.

# Requirements

- An account on AWS
- AWS CLI v2
- AWS credentials stored locally using `aws configure`
- Terraform >= 0.15
- Ansible >= 2.15.0
