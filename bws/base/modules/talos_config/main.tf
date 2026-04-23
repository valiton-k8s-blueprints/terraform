locals {
  config_patches = [
    templatefile(
      "${path.module}/talos_config_patches/machine_config.yaml",
      {
        endpoint       = var.kube_api_external_ip
        cluster_domain = var.cluster_domain
      }
    ),
    templatefile(
      "${path.module}/talos_config_patches/kubelet_certificate_rotation.yaml",
      {}
    ),
    templatefile(
      "${path.module}/talos_config_patches/openstack_ccm_config.yaml",
      {}
    )
  ]
  controlplane_config_patches = [
    templatefile(
      "${path.module}/talos_config_patches/openstack_ccm_config_controlplane.yaml",
      {
        openstack_ccm_secret = var.openstack_ccm_secret
      }
    ),
    templatefile(
      "${path.module}/talos_config_patches/keystone_auth.yaml",
      {
        k8s_keystone_auth_config    = var.k8s_keystone_auth_config
        k8s_keystone_auth_ca_crt    = var.k8s_keystone_ca
        k8s_keystone_auth_manifests = var.k8s_keystone_auth_manifests
      }
    ),
    templatefile(
      "${path.module}/talos_config_patches/pod_security_configuration.yaml",
      {
        pod_security_exemptions_namespaces = yamlencode(var.pod_security_exemptions_namespaces)
      }
    ),
    templatefile(
      "${path.module}/talos_config_patches/kubelet_serving_cert_approver.yaml",
      {}
    )
  ]
  ca_cert = base64decode(var.talos_secrets.certs.os.crt)
  ca_key  = replace(base64decode(var.talos_secrets.certs.os.key), " ED25519", "")
  mapped_secrets = {
    cluster = var.talos_secrets.cluster
    secrets = {
      bootstrap_token             = var.talos_secrets.secrets.bootstraptoken
      secretbox_encryption_secret = var.talos_secrets.secrets.secretboxencryptionsecret
    }
    trustdinfo = var.talos_secrets.trustdinfo
    certs = {
      for cert_name, cert_data in var.talos_secrets.certs :
      replace(replace(cert_name, "k8saggregator", "k8s_aggregator"), "k8sserviceaccount", "k8s_serviceaccount") =>
      { for k, v in cert_data : replace(k, "crt", "cert") => v }
    }
  }
}

data "talos_machine_configuration" "controlplane" {
  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${var.kube_api_external_ip}:${var.kube_api_external_port}"
  machine_type       = "controlplane"
  machine_secrets    = local.mapped_secrets
  kubernetes_version = var.kubernetes_version

  config_patches = concat(local.config_patches, local.controlplane_config_patches)
}

data "talos_machine_configuration" "worker" {
  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${var.kube_api_external_ip}:${var.kube_api_external_port}"
  machine_type       = "worker"
  machine_secrets    = local.mapped_secrets
  kubernetes_version = var.kubernetes_version

  config_patches = local.config_patches
}

resource "tls_private_key" "talos_client_key" {
  algorithm = "ED25519"
}

resource "tls_cert_request" "talos_client_csr" {
  private_key_pem = tls_private_key.talos_client_key.private_key_pem

  subject {
    organization = "os:admin"
  }
}

resource "tls_locally_signed_cert" "talos_client_cert" {

  cert_request_pem   = tls_cert_request.talos_client_csr.cert_request_pem
  ca_private_key_pem = local.ca_key
  ca_cert_pem        = local.ca_cert

  validity_period_hours = 24 * 365

  allowed_uses = [
    "digital_signature",
    "client_auth",
  ]
}
