# xnat-aws
Deploy XNAT on AWS using Terraform and Ansible.

Terraform is used to create the infrastructure on AWS and Ansible is then used to configure the instances for XNAT deployment.

## Requirements

- An [AWS account](https://portal.aws.amazon.com/billing/signup?refid=em_127222&redirect_url=https%3A%2F%2Faws.amazon.com%2Fregistration-confirmation#/start/email)
- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- AWS credentials stored locally using [`aws configure`](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html#:~:text=settings%20using%20commands.-,aws%20configure,-Run%20this%20command) (or [`aws configure sso`](https://docs.aws.amazon.com/cli/latest/userguide/sso-configure-profile-token.html))
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) >= 0.15
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-and-upgrading-ansible) >= 2.15.0 - we recommend installing Ansible in a virtual environment, using either [Conda](https://docs.conda.io/en/latest/miniconda.html) or [Virtualenv](https://virtualenv.pypa.io/en/latest/)
- [Other Python dependencies](configure/README.md#install-python-dependencies) - these should be installed in the same virtual environment as Ansible. These dependencies are required if you would like to create a project and upload sample data to it.

## Quick start

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

> **Note**: after the `terraform apply` steps have completed, you may need to wait 1-2 minutes
> before running the configuration. This is to allow time for the AWS instances to finish starting up.

3. [Install XNAT](configure/README.md). From the `xnat-aws/configure` directory,  first type:

```bash
python -m pip install -r requirements.txt
```

This will install Ansible and other Python dependencies. Then, from the same directory, type:


```bash
./install_xnat.sh
```

This will run several Ansible commands to install and configure XNAT.

See [`Logging into the web server`](configure/README.md#logging-in-to-the-web-server) for notes on how to log into XNAT once it has been deployed.

4. \[Optional\] [Create a sample project and upload data](configure/README.md#create-a-sample-project-and-upload-data). From the `xnat-aws/configure` directory, type:

```bash
./setup_xnat_project.sh
```

This will create a project on your XNAT server and upload data to it.

The sample data can be used for running a [workshop](https://healthbioscienceideas.github.io/MedICSS-Project-Repro-Pipelines/) on implementing reproducible medical image analysis pipelines with XNAT.

## Important!

Don't forget to destroy your infrastructure when you're finished! Otherwise you may end up with a large AWS bill at the end of the month.

To destroy the infrastructure, go to the `xnat-aws/provision` directory and type:

```bash
terraform destroy
```
