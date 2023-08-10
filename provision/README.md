# Create infrastructure on AWS using Terraform

The Terraform scripts will create the following:

- a Virtual Private Cloud (VPC) with one public subnet, 2 private subnets and required security groups
- two EC2 instances - `xnat_web` and `xnat_cserv` for the web server and [XNAT Container Service](https://wiki.xnat.org/container-service/), respectively
- an RDS instance - `xnat_db` - for the PostgreSQL database
- an EFS instance used to store data uploaded to xnat, this volume is shared beetween the web server
  and container service

## Warning

A single, **public** subnet is created in the VPC. This is to make it straightforward to configure
the instances with Ansible. However, this means that the instances will have public IP addresses and
may be vulnerable to attack. To protect against this:

- only the web server has HTTP and HTTPS ports open to the internet
- SSH access is only allowed from the IP address of the user that creates the infrastructure

## Usage

First set the necessary variables. Copy the file `xnat-aws/provision/terraform.tfvars_sample` to
`xnat-aws/provision/terraform.tfvars`. You shouldn't need to change any values but may do so if you
wish to e.g. use a `t3.large` EC2 instance for the web server.

```sh
cd provision
cp terraform.tfvars_sample terraform.tfvars
```

Then, to create the infrastructure on AWS run the following commands from within the `xnat-aws/provision` directory:

```bash
terraform init
teraform apply
```

## Output

After running `terraform apply`, the following outputs will be printed:

- `ansible_install_xnat`: the command to run to configure the infrastructure with Ansible
- `xnat_web_url`: the URL of the web server for logging into XNAT

See [`xnat-aws/configure/README.md`](../configure/README.md#deploy-xnat) for notes on running the XNAT installation.

## Destroy the infrastructure

To destroy the infrastructure, type:

```bash
terraform destroy
```
