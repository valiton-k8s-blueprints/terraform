output "controlplane_instances" {
  description = "Controlplane instances"
  value       = openstack_compute_instance_v2.controlplane
}

output "worker_instances" {
  description = "Worker instances"
  value       = openstack_compute_instance_v2.worker
}
