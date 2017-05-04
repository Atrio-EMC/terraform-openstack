# Configure the OpenStack Provider
provider "openstack" {
}

resource "openstack_compute_keypair_v2" "terraform" {
  name       = "${var.key_ssh}"
  public_key = "${file("${var.ssh_key_file}.pub")}"
}

resource "openstack_networking_floatingip_v2" "myip" {
  pool = "${var.ext-net}"
}

resource "openstack_networking_floatingip_v2" "myip2" {
  pool = "${var.ext-net}"
}

resource "openstack_blockstorage_volume_v2" "vol1" {
  name = "volume_cinder"
  size =  "${var.size}"
}


resource "openstack_networking_network_v2" "red-int" {
  name = "red-int"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subred-int" {
  name = "subred-int"
  network_id = "${openstack_networking_network_v2.red-int.id}"
  cidr = "${var.ip_subred-int}"
  ip_version = 4
  no_gateway = true
}



resource "openstack_compute_floatingip_associate_v2" "myip" {
  floating_ip = "${openstack_networking_floatingip_v2.myip.address}"
  instance_id = "${openstack_compute_instance_v2.controller.id}"
  fixed_ip    = "${openstack_compute_instance_v2.controller.network.0.fixed_ip_v4}"

  # provisioner "file" {
  #   source      = "${var.ssh_key_file}"
  #   destination = "~/.ssh/id_rsa"
  #   connection {
  #       type = "ssh"
  #       user = "ubuntu"
  #       private_key = "${file("${var.ssh_key_file}")}"
  #       host = "${openstack_networking_floatingip_v2.myip.address}"
  #       }
  # }
}

resource "openstack_compute_floatingip_associate_v2" "myip2" {
  floating_ip = "${openstack_networking_floatingip_v2.myip2.address}"
  instance_id = "${openstack_compute_instance_v2.compute1.id}"
  fixed_ip    = "${openstack_compute_instance_v2.compute1.network.0.fixed_ip_v4}"
}

resource "openstack_compute_instance_v2" "controller" {
  name = "controller"
  image_name = "${var.imagen}"
  flavor_name = "${var.sabor_controller }"
  key_pair = "${var.key_ssh}"
  security_groups = ["default"]

  metadata {
    this = "that"
  }


  network {
    name = "${var.int-net}"
    fixed_ip_v4="${var.controller_ip_ext}"
  }

  
  network {
    uuid = "${openstack_networking_network_v2.red-int.id}"
    fixed_ip_v4 = "${var.controller_ip_int}"
  }

}

resource "openstack_compute_instance_v2" "compute1" {
  name = "compute1"
  image_name = "${var.imagen}"
  flavor_name = "${var.sabor}"
  key_pair = "${var.key_ssh}"
  security_groups = ["default"]

  metadata {
    this = "that"
  }

  network {
    name = "${var.int-net}"
    fixed_ip_v4="${var.compute1_ip_ext}"
  }

  network {
    uuid = "${openstack_networking_network_v2.red-int.id}"
    fixed_ip_v4 = "${var.compute1_ip_int}" 
  }

}

# resource "openstack_blockstorage_volume_attach_v2" "va_1" {
#   volume_id = "${openstack_blockstorage_volume_v2.vol1.id}"
#   host_name = "controller"
# }