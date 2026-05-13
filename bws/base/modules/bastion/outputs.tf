output "instance" {
  description = "Bastion instance"
  value       = openstack_compute_instance_v2.bastion
}

output "public_ip" {
#  value = openstack_networking_floatingip_v2.public_ip.address
  value = "127.0.0.1" # dummy
}

