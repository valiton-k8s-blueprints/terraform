locals {
  k0s_yaml = templatefile(
    "${path.module}/templates/k0s_yaml.tftpl",
    {
      cluster_name : var.cluster_name,
      bastion_public_ip : var.bastion_public_ip,
      kube_api_external_ip : var.kube_api_external_ip,
      kube_api_external_port : var.kube_api_external_port,
      k0s_version : var.k0s_version,
      ssh_username : "ubuntu",
      ssh_port : 22,
      controlplane_instances : var.controlplane_instances,
      worker_instances : var.worker_instances,
      openstack_helm_chart_version : var.openstack_helm_chart_version
      controlplane_files : concat(
        [
          {
            path : "/var/lib/k0s/manifests/ccm/os_ccm_chart.yaml",
            content : local.os_ccm_chart
          },
          {
            path : "/var/lib/k0s/manifests/ccm/os_ccm_secret.yaml",
            content : var.openstack_ccm_secret
          },
          {
            path : "/var/lib/k0s/keystone/k8s-keystone-auth-ca.crt",
            content : var.k8s_keystone_ca
          },
          {
            path : "/var/lib/k0s/keystone/k8s-keystone-auth-webhook.yaml",
            content : var.k8s_keystone_auth_config
          }
        ],
        local.k8s_keystone_manifest_files
      )
    }
  )
  os_ccm_chart = templatefile(
    "${path.module}/templates/chart_yaml.tftpl",
    {
      name : "openstack-cloud-controller-manager"
      target_namespace : "kube-system"
      chart_name : "openstack-cloud-controller-manager"
      chart_version : var.openstack_helm_chart_version
      chart_repository : "https://kubernetes.github.io/cloud-provider-openstack"
      values : {
        nodeSelector : null,
        secret = {
          enabled = true
          create  = false
        }
        cluster = {
          name = var.cluster_name
        }
      }
    }
  )
  k8s_keystone_manifest_files = [
    for m in var.k8s_keystone_auth_manifests : {
      path : "/var/lib/k0s/manifests/keystone/${m.name}.yaml",
      content : m.contents
    }
  ]
}

resource "local_file" "k0s_yaml" {
  content  = local.k0s_yaml
  filename = "k0s.yaml"

  provisioner "local-exec" {
    when       = destroy
    command    = "k0sctl reset --force --config k0s.yaml"
    on_failure = continue
  }
}

resource "null_resource" "bootstrap_k0s" {
  depends_on = [local_file.k0s_yaml]

  provisioner "local-exec" {
    command = "k0sctl apply --config k0s.yaml"
  }

  lifecycle {
    replace_triggered_by = [local_file.k0s_yaml]
  }
}

resource "null_resource" "wait_for_k8s_keystone" {
  depends_on = [null_resource.bootstrap_k0s]

  provisioner "local-exec" {
    command = "curl --fail --retry 30  --retry-all-errors --retry-delay 10 -k https://${var.kube_api_external_ip}:${var.kube_api_external_port}/api/v1/namespaces/kube-system/status --header 'Authorization: Bearer ${var.os_token}'"
  }
}
