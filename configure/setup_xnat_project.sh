#!/bin/bash

echo "Download and unzip data"
ansible-playbook playbooks/setup_xnat_project.yml -i hosts.yml --vault-password-file=.vault_password

echo "Upload data to XNAT"
METADATA=../data/ibash/ibash-sessions.csv
DATA=../data/ibash
INVENTORY=hosts.yml
HOST=xnat_web
NETRC=../data/.netrc
python scripts/upload_data.py --metadata $METADATA --data $DATA --inventory $INVENTORY --host $HOST --netrc $NETRC
