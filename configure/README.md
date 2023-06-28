# Configure AWS infrastrucre using Ansible

To run the configuration with Ansible we will need to:

- install Ansible requirements
- run the `install_container_service.yml` and `install_xnat.yml` playbooks

These steps are done in the script `xnat-aws/configure/install_xnat.sh`. To run the script, go to the `xnat-aws/configure` directory and run the following command:

```bash
./install_xnat.sh
```

# Logging in to the web server

Once Ansible has finished configuring the server, you should be able to go to the public dns hostname of the web server and log into XNAT. To do this you need to know the URL of the web server and the credentials XNAT admin user.

## Check the URL of the web server

To check the web server URL, go to the `xnat-aws/provision` directory and type `terraform output`. This will print, among other things, the url of the web server.

## Check the XNAT admin credentials

The XNAT admin user have a username `admin_user`. The password is stored in the Ansible vault (`xnat-aws/configure/group_vars/all/vault`). From the `xnat-aws/configure` directory, run the command:

```bash
ansible-vault view group_vars/all/vault --vault-password .vault_password`
```

This will display the passwords used in the configuration. The one for the XNAT admin user is assigned to a variable called `vault_service_admin_password`.
