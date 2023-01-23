#!/bin/bash
ansible-playbook -i ansible/inventory ansible/ceph-config.yml --ask-vault-pass
bash bash/bootstrap.sh