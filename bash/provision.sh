echo "-------------------------"
echo "openstack auth credentials"
read -p "type openstack auth url" rhosp_auth_url
read -p "type openstack username" rhosp_username
read -s -p "type openstack password" rhosp_password
read -p "type openstack tenant name" rhosp_tenant
read -p "type openstack domain name" rhosp_domain
echo "-------------------------"
echo "ceph nodes configuration"
read -p "type openstack public network name" rhosp_public_net
read -p "type ceph nodes OS images" rhosp_image
read -p "type ceph admin flavor" rhosp_admin_flavor
read -p "type ceph nodes flavor" rhosp_ceph_flavor
echo "-------------------------"
echo "generating var files"
if  [ ! -d ./vars ];
then
    mkdir ./vars
fi
if [ ! -d ./secrets ];
then
    mkdir ./secrets
fi
cat << EOF > ./vars/terraform.yml
---
openstack_public_network: $rhosp_public_net
vms_image: $rhosp_image
adminhost_flavor: $rhosp_admin_flavor
ceph_flavor: $rhosp_ceph_flavor
EOF
cat << EOF > ./secrets/auth.yml
---
auth_url: $rhosp_auth_url
user_name: $rhosp_username
password: $rhosp_password
tenant_name: $rhosp_tenant
user_domain_name: $rhosp_domain
project_domain_name: $rhosp_domain
EOF
ansible-vault encrypt secrets/auth.yml
ansible-playbook ceph-provision.yml --ask-vault-pass -e "state=present"
bash config.sh