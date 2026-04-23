output "k8s_keystone_ca" {
  description = "CA for k8s-keystone"
  value       = local.k8s_keystone_ca
}

output "k8s_keystone_auth_manifests" {
  description = "Manifests for k8s-keystone"
  value       = local.k8s_keystone_auth_manifests
}

output "k8s_keystone_auth_config" {
  description = "Webhook config for k8s-keystone"
  value       = local.k8s_keystone_auth_config
}

output "openstack_ccm_secret" {
  description = "Secret YAML for Openstack CCM"
  value       = local.openstack_ccm_secret
}

