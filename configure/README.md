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
ansible-vault view group_vars/all/vault --vault-password .vault_password
```

This will display the passwords used in the configuration. The one for the XNAT admin user is assigned to a variable called `vault_service_admin_password`.


# Create a sample project and upload data

`xnat-aws` was created for running a [workshop](https://healthbioscienceideas.github.io/MedICSS-Project-Repro-Pipelines/) on implementing reproducible medical image analysis pipelines with XNAT.

The sample data can be downloaded from and AWS S3 bucket and then uploaded to our XNAT server.
## Install dependencies

First ensure all Python dependencies are installed. Activate your virtual environment, then type from the `xnat-aws/configure` directory type:

```bash
python -m pip install -r requirements.txt
```

This will install the dependencies listed in [requirements.txt](requirements.txt)

## Set up sample project

The project creation, data download form the S3 bucket, and data upload to XNAT is all handled by the script `xnat-aws/configure/setup_xnat_project.sh`. To run the script, go to the `xnat-aws/configure` directory and run the following command:

```bash
./setup_xnat_project.sh
```

## View the sample project

Once the project has been created and data uploaded, you can log into the server by going to the [URL your server is running on](#check-the-url-of-the-web-server) and logging in with the username `profX` and the password `carlos1602`.

This user is an owner of the project but is not a site-wide admin. This means the user can upload data for the project, and even delete the project, but cannot perform admin actions on the site. See [here](#check-the-xnat-admin-credentials) for logging in as an adminstrator.
