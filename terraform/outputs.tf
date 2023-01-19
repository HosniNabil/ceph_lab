output "admin_host" {
  value = "${openstack_networking_floatingip_v2.admin-host.address}"
}
output "ceph_host" {
  value = openstack_networking_floatingip_v2.ceph-host.*.address
}