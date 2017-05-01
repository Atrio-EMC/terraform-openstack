output "Controller address" {
  value = "${openstack_networking_floatingip_v2.myip.address}"
}
output "Compute1 address" {
  value = "${openstack_networking_floatingip_v2.myip2.address}"
}
