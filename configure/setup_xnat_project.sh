#!/bin/bash
set -e

echo "Download and unzip data"
ansible-playbook playbooks/setup_xnat_project.yml -i hosts.yml --vault-password-file=.vault_password
