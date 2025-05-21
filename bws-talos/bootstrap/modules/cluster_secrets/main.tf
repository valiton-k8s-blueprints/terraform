resource "kubernetes_namespace_v1" "cluster_credentials" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret_v1" "os_credentials" {
  depends_on = [kubernetes_namespace_v1.cluster_credentials]

  metadata {
    name      = var.secret_name
    namespace = var.namespace
  }
  data = {
    application_credential_id     = var.os_application_credential_id
    application_credential_secret = var.os_application_credential_secret
  }
}

resource "kubernetes_role_v1" "access_secrets" {
  depends_on = [kubernetes_namespace_v1.cluster_credentials]

  metadata {
    namespace = var.namespace
    name      = "access-${var.secret_name}"
  }
  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["authorization.k8s.io"]
    resources  = ["selfsubjectrulesreviews"]
    verbs      = ["create"]
  }
}

resource "kubernetes_service_account_v1" "access_secrets" {
  depends_on = [kubernetes_namespace_v1.cluster_credentials]

  metadata {
    namespace = var.namespace
    name      = "access-${var.secret_name}"
  }
}

resource "kubernetes_role_binding_v1" "access_secrets" {
  depends_on = [kubernetes_namespace_v1.cluster_credentials]

  metadata {
    namespace = var.namespace
    name      = "access-${var.secret_name}"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.access_secrets.metadata[0].name
    namespace = var.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.access_secrets.metadata[0].name
  }
}
