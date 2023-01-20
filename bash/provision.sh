echo "-------------------------"
echo "openstack auth credentials"
echo "type openstack auth url"
read rhosp_auth_url
echo "type openstack username"
read  rhosp_username
echo "type openstack password"
read -s rhosp_password
echo "type openstack tenant name"
read  rhosp_tenant
echo "type openstack domain name"
read  rhosp_domain
echo "-------------------------"
echo "ceph nodes configuration"
echo "type openstack public network name"
read  rhosp_public_net
echo "type ceph nodes OS images"
read  rhosp_image
echo "type ceph admin flavor"
read  rhosp_admin_flavor
echo "type ceph nodes flavor"
read  rhosp_ceph_flavor
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