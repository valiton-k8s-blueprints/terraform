output "controlplane_userdata" {
  description = "Ignition user data for controlplane"
  value       = data.ct_config.controlplane_ignition.rendered
}
