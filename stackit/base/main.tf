locals {
  name       = var.base_name
  project_id = var.project_id

  cluster_version = var.kubernetes_version

  base_node_pool = {
    name               = "${local.name}"
    os_name            = var.base_node_pool_os_name
    max_surge          = var.base_node_pool_max_surge
    max_unavailable    = var.base_node_pool_max_unavailable
    machine_type       = var.base_node_pool_machine_type
    minimum            = var.base_node_pool_min_size
    maximum            = var.base_node_pool_max_size
    availability_zones = var.availability_zones
    volume_size        = var.base_node_pool_volume_size
    volume_type        = var.base_node_pool_volume_type
    labels             = var.base_node_pool_labels
  }


}

resource "stackit_ske_cluster" "managed_cluster" {
  project_id             = local.project_id
  name                   = local.name
  kubernetes_version_min = local.cluster_version
  node_pools             = var.ske_managed_node_pools == {} ? [local.base_node_pool] : merge([var.ske_managed_node_pools, local.base_node_pool])
  maintenance = {
    enable_kubernetes_version_updates    = var.maintenance_enable_kubernetes_version_updates
    enable_machine_image_version_updates = var.maintenance_enable_machine_image_version_updates
    start                                = var.maintenance_start
    end                                  = var.maintenance_end
  }

  extensions = {
    dns = {
      enabled = var.extensions_dns_enabled
      zones   = var.extensions_dns_zones
    }
  }

}


