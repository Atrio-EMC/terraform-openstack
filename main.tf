# Configure the OpenStack Provider
provider "openstack" {
        user_name  = "demo"
        tenant_name = "demo"
        domain_name = "default"
        password  = "${var.secret_key}"
        auth_url  = "https://jupiter.gonzalonazareno.org:5000/v3"
        cacert_file = "gonzalonazareno.crt"
}


resource "openstack_compute_floatingip_v2" "myip" {
  pool = "${var.ext-net}"
}

resource "openstack_networking_network_v2" "red-ext" {
  name = "red-ext"
  admin_state_up = "true"

}

resource "openstack_networking_subnet_v2" "subred-ext" {
  name = "subred-ext"
  network_id = "${openstack_networking_network_v2.red-ext.id}"
  cidr = "${var.ip_subred-ext}"
  dns_nameservers = "${var.dns_subred-ext}"
  ip_version = 4

}

resource "openstack_networking_network_v2" "red-int" {
  name = "red-int"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subred-int" {
  name = "subred-int"
  network_id = "${openstack_networking_network_v2.red-int.id}"
  cidr = "${var.ip_subred-int}"
  #dns_nameservers = "${var.dns_subred-ext}"
  ip_version = 4

}

resource "openstack_compute_instance_v2" "cliente" {
  name = "cliente"
  region = "RegionOne"
  image_id = "${var.imagen}"
  flavor_id = "${var.sabor}"
  key_pair = "${var.key_ssh}"
  security_groups = ["default"]

  metadata {
    this = "that"
  }
  network {
    name = "demo-net"
    floating_ip = "${openstack_compute_floatingip_v2.myip.address}"

  }
  network {
    uuid = "${openstack_networking_network_v2.red-ext.id}"
    fixed_ip_v4 = "${var.gateway-ext}"
  }

}

resource "openstack_compute_instance_v2" "controller" {
  name = "controller"
  region = "RegionOne"
  image_id = "${var.imagen}"
  flavor_id = "${var.sabor}"
  key_pair = "${var.key_ssh}"
  security_groups = ["default"]

  metadata {
    this = "that"
  }

  network {
    uuid = "${openstack_networking_network_v2.red-ext.id}"
    fixed_ip_v4 = "${var.controller_ip_ext}"
  }

  network {
    uuid = "${openstack_networking_network_v2.red-int.id}"
    fixed_ip_v4 = "${var.controller_ip_int}"
  }

}

resource "openstack_compute_instance_v2" "compute1" {
  name = "compute1"
  region = "RegionOne"
  image_id = "${var.imagen}"
  flavor_id = "${var.sabor}"
  key_pair = "${var.key_ssh}"
  security_groups = ["default"]

  metadata {
    this = "that"
  }

  network {
    uuid = "${openstack_networking_network_v2.red-ext.id}"
    fixed_ip_v4 = "${var.compute1_ip_ext}"
  }

  network {
    uuid = "${openstack_networking_network_v2.red-int.id}"
    fixed_ip_v4 = "${var.compute1_ip_int}" 
  }

}