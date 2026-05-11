locals {
  k8s_keystone_auth_config = yamlencode({
    apiVersion  = "v1"
    kind        = "Config"
    preferences = {}
    clusters = [
      {
        cluster = {
          certificate-authority = "/var/keystone/k8s-keystone-auth-ca.crt"
          server                = "https://${var.kube_api_external_ip}:${var.keystone_auth_port}/webhook"
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

  k8s_keystone_auth_manifests = [
    {
      name : "keystone-auth-tls-secret",
      contents : templatefile(
        "${path.module}/templates/keystone_auth_tls_secret.yaml",
        {
          k8s_keystone_auth_crt = tls_locally_signed_cert.keystone_auth_crt.cert_pem
          k8s_keystone_auth_key = tls_private_key.keystone_auth_key.private_key_pem
        }
      )
    },
    {
      name : "keystone-auth-daemonset",
      contents : templatefile(
        "${path.module}/templates/keystone_auth_daemonset.yaml",
        {
          os_ccm_version = var.os_ccm_version
          os_auth_url    = var.os_auth_url
        }
      )
    },
    {
      name : "keystone-auth-service",
      contents : templatefile(
        "${path.module}/templates/keystone_auth_service.yaml",
        {
          keystone_auth_port = var.keystone_auth_port
        }
      )
    },
    {
      name : "keystone-auth-cluster-role-binding",
      contents : templatefile(
        "${path.module}/templates/keystone_auth_cluster_role_binding.yaml",
        {
          os_user_name = var.os_user_name
        }
      )
    },
  ]

  k8s_keystone_ca = tls_self_signed_cert.keystone_auth_ca_crt.cert_pem

  openstack_ccm_secret = templatefile(
    "${path.module}/templates/openstack_ccm_secret.yaml",
    {
      os_auth_url                      = var.os_auth_url
      os_application_credential_id     = var.os_application_credential_id
      os_application_credential_secret = var.os_application_credential_secret
      os_subnet_id                     = var.os_subnet_id
      os_floating_network_id           = var.os_floating_network_id
    }
  )
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
    common_name = var.kube_api_external_ip
  }

  ip_addresses = [var.kube_api_external_ip]
}

resource "tls_locally_signed_cert" "keystone_auth_crt" {
  cert_request_pem   = tls_cert_request.keystone_auth_csr.cert_request_pem
  ca_private_key_pem = tls_private_key.keystone_auth_ca_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.keystone_auth_ca_crt.cert_pem

  validity_period_hours = 24 * 365 * 10

  allowed_uses = ["server_auth"]
}
