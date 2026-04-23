resource "random_integer" "ip_part" {
  # prevent overlap with 10.96.0.0/12
  min = 112
  # prevent overlap with 10.244.0.0/16
  max = 243
}

resource "openstack_compute_keypair_v2" "keypair" {
  count = var.k8s_distribution == "talos" ? 0 : 1

  name       = "${var.base_name}-keypair"
  public_key = var.ssh_public_key
}

locals {
  private_network_cidr         = var.os_private_network_cidr != "" ? var.os_private_network_cidr : "10.${random_integer.ip_part.result}.0.0/16"
  openstack_helm_chart_version = replace(var.openstack_ccm_version, "v1", "2")
}

################################################################################
# Openstack network setup
################################################################################
module "network" {
  source = "./modules/network"

  name_prefix             = var.base_name
  os_public_network_name  = var.os_public_network_name
  os_private_network_name = var.os_private_network_name
  os_private_network_cidr = local.private_network_cidr
  worker_count            = var.worker_count
  controlplane_count      = var.controlplane_count
  kube_api_external_ip    = var.kube_api_external_ip
  kube_api_external_port  = var.kube_api_external_port
  keystone_auth_port      = var.keystone_auth_port
  enable_talos_api        = var.k8s_distribution == "talos"
  enable_k0s_api          = var.k8s_distribution == "k0s"
  enable_ssh_bastion      = var.k8s_distribution != "talos"
  enable_keystone_auth    = var.k8s_distribution != "kubeone"
}

################################################################################
# K8S Distribution independent config
################################################################################
module "config" {
  source = "./modules/config"

  os_ccm_version                   = var.openstack_ccm_version
  os_auth_url                      = var.os_auth_url
  os_user_name                     = var.os_user_name
  os_application_credential_id     = var.os_application_credential_id
  os_application_credential_secret = var.os_application_credential_secret
  os_floating_network_id           = module.network.public_network_id
  os_subnet_id                     = module.network.private_network_subnet_id
  kube_api_external_ip             = var.kube_api_external_ip
  keystone_auth_port               = var.keystone_auth_port
}

################################################################################
# Talos config setup
################################################################################
module "talos-config" {
  source = "./modules/talos_config"

  count = var.k8s_distribution == "talos" ? 1 : 0

  cluster_name           = var.base_name
  talos_secrets          = var.talos_secrets
  kube_api_external_ip   = var.kube_api_external_ip
  kube_api_external_port = var.kube_api_external_port
  kubernetes_version     = var.kubernetes_version

  pod_security_exemptions_namespaces = var.pod_security_exemptions_namespaces

  k8s_keystone_auth_config    = module.config.k8s_keystone_auth_config
  k8s_keystone_auth_manifests = module.config.k8s_keystone_auth_manifests
  k8s_keystone_ca             = module.config.k8s_keystone_ca
  openstack_ccm_secret        = module.config.openstack_ccm_secret
  cluster_domain              = var.cluster_domain
}

module "kubeone-config" {
  source = "./modules/kubeone_config"

  count = var.k8s_distribution == "kubeone" ? 1 : 0

  ca_crt = var.ca_crt
  ca_key = var.ca_key
}

locals {
  controlplane_user_data = {
    talos   = var.k8s_distribution == "talos" ? module.talos-config[0].controlplane_machine_configuration : null
    kubeone = var.k8s_distribution == "kubeone" ? module.kubeone-config[0].controlplane_userdata : null
    k0s     = null
  }
}

module "instances" {
  source = "./modules/instances"

  name_prefix                  = var.base_name
  worker_count                 = var.worker_count
  controlplane_count           = var.controlplane_count
  image_name                   = var.image_name
  worker_instance_flavor       = var.worker_instance_flavor
  worker_volume_type           = var.worker_volume_type
  worker_volume_size           = var.worker_volume_size
  worker_port_id               = module.network.worker_port_id
  worker_user_data             = var.k8s_distribution == "talos" ? module.talos-config[0].worker_machine_configuration : null
  controlplane_instance_flavor = var.controlplane_instance_flavor
  controlplane_volume_type     = var.controlplane_volume_type
  controlplane_volume_size     = var.controlplane_volume_size
  controlplane_port_id         = module.network.controlplane_port_id
  controlplane_user_data       = local.controlplane_user_data[var.k8s_distribution]
  keypair_name                 = var.k8s_distribution == "talos" ? null : openstack_compute_keypair_v2.keypair[0].name
}

module "bastion" {
  source = "./modules/bastion"

  count = var.k8s_distribution == "talos" ? 0 : 1

  name_prefix     = var.base_name
  image_name      = var.image_name
  instance_flavor = var.bastion_instance_flavor
  volume_type     = var.bastion_volume_type
  volume_size     = var.bastion_volume_size
  port_id         = module.network.bastion_port_id[0]
  keypair_name    = var.k8s_distribution == "talos" ? null : openstack_compute_keypair_v2.keypair[0].name
}

module "bootstrap_talos" {
  source = "./modules/talos"

  count = var.k8s_distribution == "talos" ? 1 : 0

  depends_on = [
    module.network,
    module.instances
  ]

  base_name = var.base_name

  client_configuration = {
    ca_certificate     = var.talos_secrets.certs.os.crt
    client_certificate = base64encode(module.talos-config[0].talos_client_crt)
    client_key         = base64encode(module.talos-config[0].talos_client_key)
  }

  talos_secrets = var.talos_secrets

  controlplane_count                 = var.controlplane_count
  controlplane_machine_configuration = module.talos-config[0].controlplane_machine_configuration
  controlplane_names                 = module.network.controlplane_fixed_ips
  k8s_distribution                   = var.k8s_distribution
  kube_api_external_ip               = var.kube_api_external_ip
  kube_api_external_port             = var.kube_api_external_port
  worker_count                       = var.worker_count
  worker_machine_configuration       = module.talos-config[0].worker_machine_configuration
  worker_names                       = module.network.worker_fixed_ips
  openstack_helm_chart_version       = local.openstack_helm_chart_version

  os_token = var.os_token
}

module "bootstrap_kubeone" {
  source = "./modules/kubeone"

  depends_on = [
    module.bastion,
    module.network,
    module.instances
  ]

  count = var.k8s_distribution == "kubeone" ? 1 : 0

  availability_zone                = var.availability_zone
  cluster_name                     = var.base_name
  controlplane_instances           = module.instances.controlplane_instances
  image_name                       = var.image_name
  kube_api_external_ip             = var.kube_api_external_ip
  kube_api_external_port           = var.kube_api_external_port
  kubernetes_version               = var.kubernetes_version
  max_dynamic_workers              = var.max_dynamic_workers
  min_dynamic_workers              = var.min_dynamic_workers
  cinder_csi_plugin_volume_type    = var.cinder_csi_plugin_volume_type
  os_application_credential_id     = var.os_application_credential_id
  os_application_credential_secret = var.os_application_credential_secret
  os_auth_url                      = var.os_auth_url
  os_region_name                   = var.os_region_name
  private_network_name             = module.network.private_network_name
  private_network_subnet_id        = module.network.private_network_subnet_id
  private_network_subnet_name      = module.network.private_network_subnet_name
  public_network_id                = module.network.public_network_id
  security_groups                  = module.network.security_groups
  worker_instance_flavor           = var.worker_instance_flavor
  worker_instances                 = module.instances.worker_instances
  worker_volume_size               = var.worker_volume_size
}
