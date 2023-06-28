# Configure AWS infrastrucre using Ansible

To run the configuration with Ansible we will need to:

- install Ansible requirements
- set up an Ansible vault to store secrets (passwords etc.)
- run the `install_container_service.yml` and `install_xnat.yml` playbooks

## Install dependencies

Before configuring the servers, we need to ensure Ansible has the necessary collections and roles installed. From the `configure` directory, run the following commands:

```bash
ansible-galaxy install -r playbooks/roles/requirements.yml --force
```

We use the `force` flag to ensure the collections and roles are always reinstalled even if they're already present. This is to make sure we're always using the correct versions of the roles and collections.

## Deploy XNAT

After creating the infrastructure using Terraform and installing the Ansible requirements, we can configure the servers by going to the `xnat-aws/configure` directory and running the following commands:

```bash
ansible-playbook playbooks/install_container_service.yml -i hosts.yml --vault-password-file=.vault_password
```

```bash
ansible-playbook playbooks/install_xnat.yml -i hosts.yml --vault-password-file=.vault_password
```

The first command will install the Container service on `xnat_cserv`. The second command will install and configure XNAT and PostgreSQL on the web server and database server

## Logging in to the web server

Once Ansible has finished configuring the server, you should be able to go to the public dns hostname of the web server and log into XNAT. To do this you need to know the URL of the web server and the credentials XNAT admin user.

### Check the URL of the web server

To check the web server URL, go to the `xnat-aws/provision` directory and type `terraform output`. This will print, among other things, the url of the web server.

### Check the XNAT admin credentials

The XNAT admin user have a username `admin_user`. The password is stored in the Ansible vault (`xnat-aws/configure/group_vars/all/vault`). From the `xnat-aws/configure` directory, run the command:

```bash
ansible-vault view group-vars/all/vault --vault-password .vault_password`
```

This will display the passwords used in the configuration. The one for the XNAT admin user is assigned to a variable called `vault_service_admin_password`.
