#!/bin/bash

echo "Install the required Ansible dependencies"
ansible-galaxy install -r playbooks/roles/requirements.yml --force

echo "Install the XNAT Container service"
ansible-playbook playbooks/install_container_service.yml -i hosts.yml --vault-password-file=.vault_password

echo "Install and configure XNAT"
ansible-playbook playbooks/install_xnat.yml -i hosts.yml --vault-password-file=.vault_password

echo "Show the passwords in the vault"
echo "Log into the XNAT instance using the username 'admin_user' and the password 'vault_service_admin_password' stored in the vault"
ansible-vault view group_vars/all/vault --vault-password .vault_password
