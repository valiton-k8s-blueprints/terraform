output "worker_port_id" {
  description = "IDs of networking ports for worker nodes"
  value       = [for port in openstack_networking_port_v2.worker_port : port.id]
}

output "controlplane_port_id" {
  description = "IDs of networking ports for controlplane nodes"
  value       = [for port in openstack_networking_port_v2.controlplane_port : port.id]
}

output "private_network_subnet_id" {
  description = "ID of the created private subnet"
  value       = openstack_networking_subnet_v2.private_network_subnet.id
}

output "public_network_id" {
  description = "ID of the public network"
  value       = data.openstack_networking_network_v2.public_network.id
}

output "controlplane_fixed_ips" {
  description = "Fixed (private) IPs of controlplane nodes"
  value       = [for port in openstack_networking_port_v2.controlplane_port : port.all_fixed_ips[0]]
}

output "worker_fixed_ips" {
  description = "Fixed (private) IPs of worker nodes"
  value       = [for port in openstack_networking_port_v2.worker_port : port.all_fixed_ips[0]]
}
