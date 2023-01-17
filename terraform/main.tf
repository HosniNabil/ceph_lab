terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = "1.49.0"
    }
  }
}

provider "openstack" {
  auth_url = var.auth_url
  user_name = var.user_name
  password = var.password
  user_domain_name = var.user_domain_name
  project_domain_name = var.project_domain_name
  tenant_name = var.tenant_name
}
#create ceph client network
resource "openstack_networking_network_v2" "ceph-client" {
  name = "ceph-client"
  admin_state_up = true
}
#create ceph client subnet
resource "openstack_networking_subnet_v2" "ceph-client" {
  name = "ceph-client"
  network_id = "${openstack_networking_network_v2.ceph-client.id}"
  cidr = var.ceph_client_cidr
  ip_version = 4
  allocation_pool {
    start = var.ceph_client_allocation_pool.start
    end= var.ceph_client_allocation_pool.end
  }
  gateway_ip = var.ceph_client_gw
  depends_on = [
    openstack_networking_network_v2.ceph-client
  ]
}
#create ceph client network router
data "openstack_networking_network_v2" "public_net" {
  name = var.openstack_public_network
}
resource "openstack_networking_router_v2" "ceph-client" {
  name = "ceph-client"
  admin_state_up = true
  external_network_id = data.openstack_networking_network_v2.public_net.id
}
resource "openstack_networking_router_interface_v2" "ceph-client" {
  router_id = "${openstack_networking_router_v2.ceph-client.id}"
  subnet_id = "${openstack_networking_subnet_v2.ceph-client.id}"
  depends_on = [
    openstack_networking_subnet_v2.ceph-client
  ]
}

#create ceph replication network
resource "openstack_networking_network_v2" "ceph-replication" {
  name = "ceph-replication"
  admin_state_up = true
}
#create ceph replication subnet
resource "openstack_networking_subnet_v2" "ceph-replication" {
  name = "ceph-replication"
  network_id = "${openstack_networking_network_v2.ceph-replication.id}"
  cidr = var.ceph_replication_cidr
  ip_version = 4
  allocation_pool {
    start = var.ceph_replication_allocation_pool.start
    end= var.ceph_replication_allocation_pool.end
  }
  depends_on = [
    openstack_networking_network_v2.ceph-replication
  ]
}
#security group
resource "openstack_networking_secgroup_v2" "ceph" {
  name = "ceph"
  description = "ceph security group"  
}
resource "openstack_networking_secgroup_rule_v2" "alltcp" {
  security_group_id = "${openstack_networking_secgroup_v2.ceph.id}"
  direction = "ingress"
  ethertype = "IPv4"
  remote_ip_prefix = "0.0.0.0/0"
  protocol = "tcp"
  port_range_min = 1
  port_range_max = 65535
  depends_on = [
    openstack_networking_secgroup_v2.ceph
  ]
}
resource "openstack_networking_secgroup_rule_v2" "alludp" {
  security_group_id = "${openstack_networking_secgroup_v2.ceph.id}"
  direction = "ingress"
  ethertype = "IPv4"
  remote_ip_prefix = "0.0.0.0/0"
  protocol = "udp"
  port_range_min = 1
  port_range_max = 65535
  depends_on = [
    openstack_networking_secgroup_v2.ceph
  ]
}
resource "openstack_networking_secgroup_rule_v2" "allicmp" {
  security_group_id = "${openstack_networking_secgroup_v2.ceph.id}"
  direction = "ingress"
  ethertype = "IPv4"
  remote_ip_prefix = "0.0.0.0/0"
  protocol = "icmp"
  port_range_min = 1
  port_range_max = 255
  depends_on = [
    openstack_networking_secgroup_v2.ceph
  ]
}
#create ceph admin host
resource "openstack_compute_instance_v2" "admin-host" {
  depends_on = [
    openstack_networking_secgroup_v2.ceph,
    openstack_networking_subnet_v2.ceph-client,
    openstack_networking_subnet_v2.ceph-replication
  ]
  name = "ceph-host0"
  image_name = var.vms_image
  flavor_name = var.adminhost_flavor
  security_groups = ["ceph"]
  key_pair = "nabil_ssh"
  network {
    uuid = openstack_networking_network_v2.ceph-client.id
  }
  network {
    uuid = openstack_networking_network_v2.ceph-replication.id
  }
}
#create osd volumes
resource "openstack_blockstorage_volume_v2" "ceph-osd" {
  count = 6
  size = 100
  name = "${format("osd-%02d", count.index + 1 )}"
}
#create ceph hosts 
resource "openstack_compute_instance_v2" "ceph-host" {
  depends_on = [
    openstack_networking_secgroup_v2.ceph,
    openstack_networking_subnet_v2.ceph-client,
    openstack_networking_subnet_v2.ceph-replication,
    openstack_blockstorage_volume_v2.ceph-osd
  ]
  count = 3
  name = "${format("ceph-host%02d", count.index)}"
  image_name = var.vms_image
  flavor_name = var.ceph_flavor
  security_groups = ["ceph"]
  key_pair = "nabil_ssh"
  network {
    uuid = "${openstack_networking_network_v2.ceph-client.id}"
  }
  network {
    uuid = "${openstack_networking_network_v2.ceph-replication.id}"
  }
}
#attach osd volumes
resource "openstack_compute_volume_attach_v2" "ceph-osd0" {
  count = 3
  instance_id = "${openstack_compute_instance_v2.ceph-host[count.index].id}"
  volume_id = "${openstack_blockstorage_volume_v2.ceph-osd[count.index].id}"
}
resource "openstack_compute_volume_attach_v2" "ceph-osd1" {
  count = 3
  instance_id = "${openstack_compute_instance_v2.ceph-host[count.index].id}"
  volume_id = "${openstack_blockstorage_volume_v2.ceph-osd[count.index + 3 ].id}"
}
#floating ip
resource "openstack_networking_floatingip_v2" "admin-host" {
  pool = var.openstack_public_network
}

resource "openstack_compute_floatingip_associate_v2" "admin-host" {
  floating_ip = "${openstack_networking_floatingip_v2.admin-host.address}"
  instance_id = "${openstack_compute_instance_v2.admin-host.id}"
}

resource "openstack_networking_floatingip_v2" "ceph-host" {
  pool = var.openstack_public_network
  count = 3
}
resource "openstack_compute_floatingip_associate_v2" "ceph-host" {
  count = 3
  floating_ip = "${openstack_networking_floatingip_v2.ceph-host[count.index].address}"
  instance_id = "${openstack_compute_instance_v2.ceph-host[count.index].id}"
}