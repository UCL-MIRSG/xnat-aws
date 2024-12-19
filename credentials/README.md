# Generate credentials

The XNAT deployment will need two sets of credentials created:

1. An SSH key-pair for SSH access into the AWS servers (so we can run the
   configuration)
2. A set of passwords for the XNAT web server, database, etc.

## Usage

To generate these credentials, from the `xnat-aws/credentials` directory run the
commands:

```bash
terraform init
terraform apply
```

The generated private and public SSH keys will be saved in
`xnat-aws/ssh/aws-rsa` and `xnat-aws/ssh/aws-rsa.pub`, respectively.

The generated passwords are used to create and encrypt an Ansible vault. The
vault is saved in `xnat-aws/configure/group_vars/all/vault` and the password to
decrypt it is in `xnat-aws/configure/.vault_password`.

Once you have generated these credentials, you can
[create the infrastructure on AWS](../provision/README.md).

Note, you only need to generate these credentials once - you can then create and
destroy infrastructure on AWS re-using the same set of credentials.
