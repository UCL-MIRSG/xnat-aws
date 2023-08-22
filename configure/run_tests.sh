#!/bin/bash
set -e

echo "Test XNAT setup with multiple users"
ansible-playbook playbooks/test-multiple_xnat_users.yml -i hosts.yml --vault-password-file=.vault_password
