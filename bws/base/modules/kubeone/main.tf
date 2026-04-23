locals {
  kubeone_yaml = templatefile(
    "${path.module}/templates/kubeone_yaml.tftpl",
    {
      cluster_name : var.cluster_name,
      kube_api_external_ip : var.kube_api_external_ip,
      kube_api_external_port : var.kube_api_external_port,
      os_auth_url : var.os_auth_url,
      os_application_credential_id : var.os_application_credential_id,
      os_application_credential_secret : var.os_application_credential_secret,
      os_region_name : var.os_region_name,
      public_network_id : var.public_network_id,
      private_network_name : var.private_network_name
      private_network_subnet_id : var.private_network_subnet_id,
      private_network_subnet_name : var.private_network_subnet_name,
      security_groups : var.security_groups,
      kubernetes_version : var.kubernetes_version,
      controlplane_instances : var.controlplane_instances,
      worker_instances : var.worker_instances,
      worker_instance_flavor : var.worker_instance_flavor,
      worker_volume_size : var.worker_volume_size,
      operating_system : "flatcar",
      image_name : var.image_name,
      availability_zone : var.availability_zone,
      min_dynamic_workers : var.min_dynamic_workers,
      max_dynamic_workers : var.max_dynamic_workers,
      ssh_username : "core",
      ssh_port : 22
    }
  )
  storageclass_yaml = templatefile(
    "${path.module}/templates/storageclass_yaml.tftpl",
    {
      cinder_csi_plugin_volume_type = var.cinder_csi_plugin_volume_type
    }
  )
  credentials = yamlencode({
    OS_REGION_NAME                   = var.os_region_name,
    OS_AUTH_URL                      = var.os_auth_url,
    OS_APPLICATION_CREDENTIAL_ID     = var.os_application_credential_id,
    OS_APPLICATION_CREDENTIAL_SECRET = var.os_application_credential_secret,
    OS_AUTH_TYPE                     = "v3applicationcredential"
  })
}

resource "local_file" "kubeone_yaml" {
  depends_on = [local_file.credentials_yaml]

  content  = local.kubeone_yaml
  filename = "kubeone.yaml"

  provisioner "local-exec" {
    when       = destroy
    command    = "kubeone reset -y -m kubeone.yaml -c credentials.yaml"
    on_failure = continue
  }
}

resource "local_file" "credentials_yaml" {
  content  = local.credentials
  filename = "credentials.yaml"
}

resource "local_file" "storageclass_yaml" {
  content  = local.storageclass_yaml
  filename = "addons/storageclass.yaml"
}

resource "null_resource" "bootstrap_kubeone" {
  depends_on = [local_file.kubeone_yaml, local_file.credentials_yaml]

  provisioner "local-exec" {
    command = "kubeone apply -y -m kubeone.yaml -c credentials.yaml"
  }

  lifecycle {
    replace_triggered_by = [local_file.kubeone_yaml]
  }
}
