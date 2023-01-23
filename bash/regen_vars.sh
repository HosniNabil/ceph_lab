rm -rf ansible/secrets ansible/vars
echo "-------------------------"
echo "openstack auth credentials"
read -p "type openstack auth url:  " rhosp_auth_url
read -p "type openstack username:  " rhosp_username
read -s -p "type openstack password:  " rhosp_password
read -p "type openstack tenant name:  " rhosp_tenant
read -p "type openstack domain name:  " rhosp_domain
echo "-------------------------"
echo "ceph nodes configuration"
read -p "type openstack public network name:  " rhosp_public_net
read -p "type ceph nodes OS images:  " rhosp_image
read -p "type ceph admin flavor:  " rhosp_admin_flavor
read -p "type ceph nodes flavor:  " rhosp_ceph_flavor
echo "-------------------------"
echo "RHSM auth credentials"
read -p 'type RHSM username:  ' rhsm_username
read -s -p "type RHSM password:  " rhsm_password
read -p "type RHSM pool id:  " rhsm_pool
echo "-------------------------"
echo "generating var files"
if  [ ! -d ansible/vars ];
then
    mkdir ansible/vars
fi
if [ ! -d ansible/secrets ];
then
    mkdir ansible/secrets
fi
cat << EOF > ./ansible/vars/terraform.yml
---
openstack_public_network: $rhosp_public_net
vms_image: $rhosp_image
adminhost_flavor: $rhosp_admin_flavor
ceph_flavor: $rhosp_ceph_flavor
EOF
cat << EOF > ./ansible/secrets/auth.yml
---
auth_url: $rhosp_auth_url
user_name: $rhosp_username
password: $rhosp_password
tenant_name: $rhosp_tenant
user_domain_name: $rhosp_domain
project_domain_name: $rhosp_domain
EOF
cat << EOF > ./ansible/secrets/rhsm.yml
---
rhsm_username: $rhsm_username
rhsm_password: $rhsm_password
rhsm_pool_id: $rhsm_pool
EOF
ansible-vault encrypt ansible/secrets/auth.yml ansible/secrets/rhsm.yml
bash installer.sh