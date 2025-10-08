locals {
  k8s_keystone_auth_config = yamlencode({
    apiVersion  = "v1"
    kind        = "Config"
    preferences = {}
    clusters = [
      {
        cluster = {
          certificate-authority = "/var/keystone/k8s-keystone-auth-ca.crt"
          server                = "https://127.0.0.1:8443/webhook"
        }
        name = "webhook"
      }
    ]
    users = [
      {
        name : "webhook"
      }
    ]
    contexts = [
      {
        context = {
          cluster = "webhook"
          user    = "webhook"
        }
        name = "webhook"
      }
    ]
    current-context = "webhook"
  })
  config_patches = [
    templatefile(
      "${path.module}/talos_config_patches/machine_config.yaml",
      {
        endpoint = var.kube_api_external_ip
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
        os_ccm_version                   = var.os_ccm_version
        os_auth_url                      = var.os_auth_url
        os_application_credential_id     = var.os_application_credential_id
        os_application_credential_secret = var.os_application_credential_secret
        os_floating_network_id           = var.public_network_id
        os_subnet_id                     = var.private_network_subnet_id
      }
    ),
    templatefile(
      "${path.module}/talos_config_patches/keystone_auth.yaml",
      {
        os_ccm_version           = var.os_ccm_version
        os_auth_url              = var.os_auth_url
        os_user_name             = var.os_user_name
        k8s_keystone_auth_config = local.k8s_keystone_auth_config
        k8s_keystone_auth_crt    = tls_locally_signed_cert.keystone_auth_crt.cert_pem
        k8s_keystone_auth_key    = tls_private_key.keystone_auth_key.private_key_pem
        k8s_keystone_auth_ca_crt = tls_self_signed_cert.keystone_auth_ca_crt.cert_pem
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

resource "tls_private_key" "keystone_auth_ca_key" {
  algorithm = "ED25519"
}

resource "tls_private_key" "keystone_auth_key" {
  algorithm = "ED25519"
}

resource "tls_self_signed_cert" "keystone_auth_ca_crt" {
  private_key_pem = tls_private_key.keystone_auth_ca_key.private_key_pem

  subject {
    common_name = "keystone-auth-ca"
  }

  validity_period_hours = 24 * 365 * 10
  is_ca_certificate     = true
  allowed_uses          = ["cert_signing"]
}

resource "tls_cert_request" "keystone_auth_csr" {
  private_key_pem = tls_private_key.keystone_auth_key.private_key_pem

  subject {
    common_name = "127.0.0.1"
  }

  ip_addresses = ["127.0.0.1"]
}

resource "tls_locally_signed_cert" "keystone_auth_crt" {
  cert_request_pem   = tls_cert_request.keystone_auth_csr.cert_request_pem
  ca_private_key_pem = tls_private_key.keystone_auth_ca_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.keystone_auth_ca_crt.cert_pem

  validity_period_hours = 24 * 365 * 10

  allowed_uses = ["server_auth"]
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
