# Create infrastructure on AWS using Terraform

The Terraform scripts will create the following infrastructure on AWS:

<p align="center" width="100%">
    <img src="../assets/xnat-aws-architecture.png" alt="XNAT-AWS architecture" width="70%" >
</p>

- a Virtual Private Cloud (VPC) with one public subnet two private subnets
- two EC2 instances - `xnat_web` and `xnat_cserv` for the web server and [XNAT Container Service](https://wiki.xnat.org/container-service/), respectively
- an RDS instance - `xnat_db` - for managing the PostgreSQL database
- an EFS instance used to store data uploaded to xnat; this volume is mounted on both the web server and Container Service server
- security groups to manage access to the servers

<details>
  <summary>Notes on the infrastructure that is created</summary>

## Instance types

We have found that

## Subnets and availability zones

We will create three subnets in two availability zones, but deploy instance in only two subnets in a single availability zone. Three subnets are created because the RDS service [requires]() that both a private and database subnet is created. Similarly, we specify two availability zones as this is a [requirement for using RDS, even in single-availbility zone mode]().

## Security groups and access

### Extending access to other IP addresses



</details>

## Warning!

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
