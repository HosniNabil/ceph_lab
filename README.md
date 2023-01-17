# ceph_lab
## Lab components & sizing
the lab is POC for Red Hat Ceph Storage and it is not meant for porduction environment.
the following ceph components will de deployed:
- host0: admin host
- host1: colocated OSD, MON/MGR and RadosGW
- host2: colocated OSD, MON/MGR and RadosGW
- host3: colocated OSD, MON/MGR

the lab will be provisioned on an Openstack cluster using terraform.
Use the following command to provision the VMs:
```
terraform init
terraform plan -var-file=terraform.tfvars -var-file=secret.tfvars
terraform apply -var-file=terraform.tfvars -var-file=secret.tfvars
```
the flavor "Medium 50G" will be used for th admin host and the flavor "OKD-Compute" will be used for the rest of the hosts

