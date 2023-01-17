#provider vars
variable "auth_url" {
  type = string
}
variable "user_name" {
  type = string
}
variable "password" {
  type = string
  sensitive = true
}
variable "user_domain_name" {
  type = string
}
variable "project_domain_name" {
  type = string
}
variable "tenant_name" {
  type = string
}

#VMs vars
variable "ceph_client_cidr" {
  type = string
  default = "172.16.0.0/24"
}
variable "ceph_client_allocation_pool" {
  type = map
  default = {
    start = "172.16.0.10"
    end = "172.16.0.100"
  }
}
variable "ceph_client_gw" {
  type = string
  default = "172.16.0.1"
}
variable "openstack_public_network" {
  type = string
}
variable "ceph_replication_cidr" {
  type = string
  default = "172.16.1.0/24"
}
variable "ceph_replication_allocation_pool" {
  type = map
  default = {
    start = "172.16.1.10"
    end = "172.16.1.100"
  }
}
variable "vms_image" {
  type = string
}
variable "adminhost_flavor" {
  type = string
}

variable "ceph_flavor" {
  type = string
}