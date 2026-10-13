mock_provider "talos" {}
mock_provider "tls" {}

variables {
  cluster_name                       = "test-cluster"
  kube_api_external_ip               = "192.0.2.10"
  kube_api_external_port             = 6443
  kubernetes_version                 = "v1.36.2"
  cluster_domain                     = "cluster.local"
  pod_security_exemptions_namespaces = []
  k8s_keystone_ca                    = "mock-ca"
  k8s_keystone_auth_config           = "mock-config"
  k8s_keystone_auth_manifests        = []
  openstack_ccm_secret               = "mock-secret"
  talos_secrets = {
    cluster = {
      id     = "mock-cluster"
      secret = "mock-cluster-secret"
    }
    secrets = {
      bootstraptoken            = "mock-bootstrap-token"
      secretboxencryptionsecret = "mock-encryption-secret"
    }
    trustdinfo = {
      token = "mock-trust-token"
    }
    certs = {
      etcd = {
        crt = base64encode("mock-certificate")
        key = base64encode("mock-key")
      }
      k8s = {
        crt = base64encode("mock-certificate")
        key = base64encode("mock-key")
      }
      k8saggregator = {
        crt = base64encode("mock-certificate")
        key = base64encode("mock-key")
      }
      k8sserviceaccount = {
        key = base64encode("mock-key")
      }
      os = {
        crt = base64encode("mock-certificate")
        key = base64encode("mock-key")
      }
    }
  }
}

run "preserve_config_contract" {
  command = plan

  assert {
    condition     = data.talos_machine_configuration.controlplane.talos_version == "v1.13"
    error_message = "The control-plane configuration contract must remain pinned across provider upgrades."
  }

  assert {
    condition     = data.talos_machine_configuration.worker.talos_version == "v1.13"
    error_message = "The worker configuration contract must remain pinned across provider upgrades."
  }
}