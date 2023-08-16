# Create infrastructure on AWS using Terraform

The Terraform scripts will create the following infrastructure on AWS:

<p align="center" width="100%">
    <img src="../assets/xnat-aws-architecture.png" alt="XNAT-AWS architecture" width="70%" >
</p>

- a Virtual Private Cloud (VPC), a public subnet, and two private subnets
- two EC2 instances - `xnat_web` and `xnat_cserv` for the web server and [XNAT Container Service](https://wiki.xnat.org/container-service/), respectively
- an RDS instance - `xnat_db` - for managing the PostgreSQL database
- an EFS instance used to store data uploaded to xnat; this volume is mounted on both the web server and Container Service server
- security groups to manage access to the servers

<details><summary>Notes on the infrastructure that is created</summary>

### Instance types

The smallest instance types (`t2.nano`) do not provide enough RAM for running XNAT. We have found that we need to use `t3.large` instances for the Container Service and database, and `t3.large` instances for the web server, to prevent the site from crashing when uploading data or running containers.

You can change the instance type used by setting `ec2_instance_type` in your `xnat-aws/provision/terraform.tfvars` file, e.g.:

```terraform
ec2_instance_types = {
  "xnat_web"   = "t3.large"
  "xnat_db"    = "db.t3.large"
  "xnat_cserv" = "t3.large"
}
```

You can also increase the amount of RAM reserved for Java (and thus XNAT) in the Ansible configuration. In the file `xnat-aws/configure/group_vars/web/vars/tomcat.yml` you would need to modify the `java.mem` variable, e.g.:

```yaml
java_mem:
  Xms: "512M"
  Xmx: "6G"
  MetaspaceSize: "300M"
```

### Subnets and availability zones

We create a public and private subnet in a single availability zone, and this is where all resources are deployed. However, we also create a second private subnet in a second availability zone, but nothing is deployed here.

This is due a [requirement of RDS to have subnets defined in at least two availability zones, even if you're deploying in a single availability zone](https://repost.aws/questions/QUf7DbNMKFQmWiRg8oMB0obA/why-must-an-rds-always-have-two-subnets#ANurWZpEHBRPa1SwrtRh9Q9w). but deploy instance in only two subnets in a single availability zone.

### Security groups and access

We create a security group for each instance - the web server, database, and container service.

#### Web server security group

The web server security group allows SSH, HTTP, and HTTPS access from the IP address from which Terraform was run (i.e. your own IP address). Access is restricted for security reasons.

SSH access is required to configure the server using Ansible.

#### Database security group

The database security group only allows access to port 5432 (for connecting to the database). Access is limited to the web server only - all other connections will be refused.

#### Container Service security group

The Container Service security group allows SSH access from the IP address from which Terraform was ran. It also allows access to port 2376 (for the Container Service) from the web server only.

SSH access is required to configure the server using Ansible.

#### Extending access to other IP addresses

HTTP access to the web server can be extended to other IP addresses through the `extend_http_cidr`
variable. For example, to allow access from all IP addresses, in the file `xnat-aws/provision/terraform.tfvar`:

```
extend_http_cidr = [
  "0.0.0.0/0",
]
```

Similarly, SSH access to the web server and Container Service server can be extended to other IP addresses through the `extend_SSH` variable:

```
extend_ssh_cidr = [
  "0.0.0.0/0",
]
```

However, extending access to all IP addresses is not recommended.

</details>

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
