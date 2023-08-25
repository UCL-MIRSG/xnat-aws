#!/bin/bash
set -e

N_USERS=$1
DEFAULT='4'
N_USERS="${N_USERS:=$DEFAULT}"

echo "Test XNAT setup with $N_USERS users"
ansible-playbook playbooks/test-multiple_xnat_users.yml -i hosts.yml \
    --vault-password-file=.vault_password -e "n_users=$N_USERS"
