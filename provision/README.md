# Create infrastructure on AWS using Terraform

The Terraform scripts will create the following:

- a Virtual Private Cloud (VPC) with a public subnet and required security groups
- three EC2 instances - `xnat_web`, `xnat_db`, and `xnat_cserv` for the web server, database, and [XNAT Container Service](https://wiki.xnat.org/container-service/), respectively.

## Warning

A single, **public** subnet is created in the VPC. This is to make is straightforwards to configure the instances with Ansible. However, it means that the instances will have public IP addresses and may be vulnerable to attack. To protect against this:

- only the web server has HTTP and HTTPS ports open to the internet
- SSH access is only allowed from the IP address of the user that creates the infrastructure

## Usage

First set the necessary variables. Copy the file `xnat-aws/provision/terraform.tfvars_sample` to `xnat-aws/provision/terraform.tfvars`. You shouldn't need to change any values but may do so if you wish to e.g. use a `t2.large` EC2 instance for the web server.

Then, to create the infrastructure on AWS run the following commands from within the `xnat-aws/provision` directory:

```bash
terraform init
teraform apply
```

## Output

After running `terraform apply`, the following outputs will be prints:

- the command to run to configure the infrastructure with Ansible
- the command to run to view the contents of the Ansible vault
- the URL of the web server for logging into XNAT

See [`xnat-aws/configure/README.md`](../configure/README.md#deploy-xnat) for notes on running the XNAT installation.

## Destroy the infrastructure

To destroy the infrastructure:

```bash
terraform destroy
```
