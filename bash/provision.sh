#!/bin/bash
ansible-playbook ansible/ceph-provision.yml --ask-vault-pass -e "state=present"
bash bash/config.sh