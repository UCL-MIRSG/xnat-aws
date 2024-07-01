#!/bin/bash
set -e

echo "Install the required Ansible dependencies"
ansible-galaxy install -r playbooks/roles/requirements.yml --force

echo "Install and configure XNAT"
ansible-playbook playbooks/install_xnat.yml -i hosts.yml --vault-password-file=.vault_password
