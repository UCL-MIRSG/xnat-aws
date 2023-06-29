# xnat-aws
Deploy XNAT on AWS using Terraform and Ansible.

Terraform is used to create the infrastructure on AWS and Ansible is then used to configure the instances for XNAT deployment.

# Requirements

- An [AWS account](https://portal.aws.amazon.com/billing/signup?refid=em_127222&redirect_url=https%3A%2F%2Faws.amazon.com%2Fregistration-confirmation#/start/email)
- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- AWS credentials stored locally using [`aws configure`](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html#:~:text=settings%20using%20commands.-,aws%20configure,-Run%20this%20command) (or [`aws configure sso`](https://docs.aws.amazon.com/cli/latest/userguide/sso-configure-profile-token.html))
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) >= 0.15
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-and-upgrading-ansible) >= 2.15.0 - we recommend installing Ansible in a virtual environment, using either [Conda](https://docs.conda.io/en/latest/miniconda.html) or [Virtualenv](https://virtualenv.pypa.io/en/latest/)

# Quick start

Once you have installed and set up the requirements, there are three steps to deploying XNAT on AWS:

1. [Generate credentials](credentials/README.md). From the `xnat-aws/credentials` directory, type:

```bash
terraform init
terraform apply
```

This will will create and SSH key and various passwords that will be used for accessing the AWS servers and configuring XNAT.

2. [Create the AWS instances](provision/README.md). From the `xnat-aws/provision` directory, type:

```bash
terraform init
terraform apply
```

This will create the infrastructure on AWS.

3. [Install XNAT](configure/README.md). From the `xnat-aws/configure` directory, type:

```bash
./install_xnat.sh
```

This will run several Ansible commands to install and configure XNAT.

See [`Logging into the web server`](configure/README.md#logging-in-to-the-web-server) for notes on how to log into XNAT once it has been deployed.
