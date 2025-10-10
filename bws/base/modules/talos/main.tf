resource "talos_machine_configuration_apply" "controlplane" {
  count = var.k8s_distribution == "talos" ? var.controlplane_count : 0

  client_configuration = var.client_configuration
  endpoint             = var.kube_api_external_ip
  node                 = var.controlplane_names[count.index]

  machine_configuration_input = var.controlplane_machine_configuration
}

resource "talos_machine_configuration_apply" "worker" {
  count = var.worker_count

  depends_on = [talos_machine_configuration_apply.controlplane]

  client_configuration = var.client_configuration
  endpoint             = var.kube_api_external_ip
  node                 = var.worker_names[count.index]

  machine_configuration_input = var.worker_machine_configuration
}

########################
# Boostrap cluster
########################
resource "talos_machine_bootstrap" "cluster" {
  depends_on = [
    talos_machine_configuration_apply.controlplane,
    talos_machine_configuration_apply.worker
  ]

  client_configuration = var.client_configuration

  node     = var.controlplane_names[0]
  endpoint = var.kube_api_external_ip
}

data "talos_cluster_health" "talos" {
  depends_on = [talos_machine_bootstrap.cluster]

  client_configuration = var.client_configuration

  control_plane_nodes = var.controlplane_names
  worker_nodes        = var.worker_names
  endpoints           = [var.kube_api_external_ip]
}

data "talos_client_configuration" "talos" {
  cluster_name         = var.base_name
  client_configuration = var.client_configuration
  endpoints            = [var.kube_api_external_ip]
}

resource "helm_release" "openstack_cloud_controller_manager" {
  depends_on = [data.talos_cluster_health.talos]

  name       = "openstack-cloud-controller-manager"
  chart      = "openstack-cloud-controller-manager"
  version    = var.openstack_helm_chart_version
  repository = "https://kubernetes.github.io/cloud-provider-openstack"
  namespace  = "kube-system"

  values = [yamlencode({
    secret = {
      enabled = true
      create  = false
    }
    cluster = {
      name = var.base_name
    }
  })]

  wait = true
}
