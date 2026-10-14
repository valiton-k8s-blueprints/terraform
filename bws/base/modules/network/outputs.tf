output "bastion_port_id" {
  description = "IDs of networking ports for bastion node"
  value       = [for port in openstack_networking_port_v2.bastion_port : port.id]
}

output "worker_port_id" {
  description = "IDs of networking ports for worker nodes"
  value       = [for port in openstack_networking_port_v2.worker_port : port.id]
}

output "controlplane_port_id" {
  description = "IDs of networking ports for controlplane nodes"
  value       = [for port in openstack_networking_port_v2.controlplane_port : port.id]
}

output "private_network_id" {
  description = "ID of the selected private network"
  value       = local.private_network_id
}

output "private_network_name" {
  description = "Name of the selected private network"
  value       = local.private_network_name
}

output "private_network_subnet_id" {
  description = "ID of the selected private subnet"
  value       = local.private_network_subnet_id
}

output "private_network_subnet_name" {
  description = "Name of the selected private subnet"
  value       = local.private_network_subnet_name
}

output "private_network_subnet_cidr" {
  description = "Actual IPv4 CIDR of the selected private subnet"
  value       = local.private_network_subnet_cidr
}

output "private_network_router_name" {
  description = "Name of the managed router, or null for existing networking"
  value       = local.create_private_network ? openstack_networking_router_v2.private_network_router[0].name : null
}

output "public_network_id" {
  description = "ID of the public network"
  value       = data.openstack_networking_network_v2.public_network.id
}

output "security_groups" {
  description = "Created security groups"
  value       = [openstack_networking_secgroup_v2.external, openstack_networking_secgroup_v2.private_network_allow_internal]
}

output "internal_security_group_name" {
  description = "Created internal security group"
  value       = openstack_networking_secgroup_v2.private_network_allow_internal.name
}

output "internal_security_group_id" {
  description = "ID of the created internal security group"
  value       = openstack_networking_secgroup_v2.private_network_allow_internal.id
}

output "controlplane_fixed_ips" {
  description = "Fixed (private) IPs of controlplane nodes"
  value       = [for port in openstack_networking_port_v2.controlplane_port : port.all_fixed_ips[0]]
}

output "worker_fixed_ips" {
  description = "Fixed (private) IPs of worker nodes"
  value       = [for port in openstack_networking_port_v2.worker_port : port.all_fixed_ips[0]]
}
