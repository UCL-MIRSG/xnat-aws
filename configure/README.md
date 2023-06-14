# Configure AWS infrastrucre using Ansible

To run the configuration with Ansible we will need to:

- install Ansible requirements
- set up an Ansible vault to store secrets (passwords etc.)
- run the `install_xnat.yml` playbook

## Install dependencies

Before configuring the servers, we need to ensure Ansible has the necessary collections and roles installed. From the `configure` directory, run the following commands:

```bash
ansible-galaxy collection install -r playbooks/roles/requirements.yml --force
ansible-galaxy role install -r playbooks/roles/requirements.yml --force
```

We use to `force` flag to ensure the collections and roles are always re-installed even if they're already present. This is to make sure we're always using the correct versions of the roles and collections.

## Set up vault

You will need to generate **three** passwords for the configuration.

Two passwords will be stored in an Ansible vault, one each for:

- the xnat admin user
- the postgresql user

To create the vault:

- go to the directory `xnat-aws/configure/group_vars/all`
- copy the file `vault_sample` to `vault` (this will overwrite the current `vault` file)
- edit the file to add your passwords - DO NOT put your passwords into `vault_sample` as this file will not be encrypted

A third password will be used to encrypt and decrypt your vault. Create a file `xnat-aws/configure/.vault_password` and add your password to it. **Note**, this file is ignored by git and should NOT be checked into version control.

Now, we're ready to encrypt the vault you created. In the directory `xnat-aws/configure/group_vars/all`, run the following command:

```
ansible-vault encrypt vault --vault-password-file ../../.vault_password
```

## Deploy XNAT

After creating the infrastructure using Terraform and installing the Ansible requirements, we can configure the servers by going to the `xnat-aws/configure` directory and running the following command:

```bash
ansible-playbook playbooks/install_xnat.yml -u ec2-user -i hosts.yml --vault-password-file=.vault_password --key-file '../ssh/aws_rsa.pem' --ssh-common-args='-o StrictHostKeyChecking=accept-new'
```

**Note**, we set `StrictHostKeyChecking=accept-new` to automatically accept fingerprints for new hosts. This means we still do host key checking but we do not need to explicitly accept keys for new hosts.

## Logging in to the web server

Once Ansible has finished configuring the server, you should be able to go to the public dns hostname of the web server and log into xnat. To check the hostname, go to the `xnat-aws/provision` directory and type `terraform output`. This will print, among other things, the hostname of the web server.
