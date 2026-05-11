output "controlplane_userdata" {
  description = "User data for controlplane"
  value       = var.os == "flatcar" ? local.content_ignition : local.content_cloud_init
}
