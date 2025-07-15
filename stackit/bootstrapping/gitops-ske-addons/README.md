# Terraform STACKIT Gitops SKE Addons Module

## Overview
This module is an extension to the Terraform base module for STACKIT. It is also based on the gitops-bridge concept. 
The [example](https://github.com/valiton-k8s-blueprints/examples/blob/main/stackit/main.tf) linked below also implements the approach how you can use STACKIT DNS for DNS01 as DNS01 ACME Issuer with Cert-Manager, based on the DNS tutorial from STACKIT:
https://docs.stackit.cloud/stackit/en/how-to-use-stackit-dns-for-dns01-to-act-as-a-dns01-acme-issuer-with-cert-manager-152633984.html
Additionally, in the  [example](https://github.com/valiton-k8s-blueprints/examples/blob/main/stackit/main.tf) we use the ExternalSecrets plugin together with the STACKIT Secrets Manager, which in turn uses a HashiCorp Vault compatible API.

## Prerequisite:
Create the authentication for the Terraform provider: https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs#authentication
As this module is an addon, the STACKIT base module must also be installed. Important for the [example](https://github.com/valiton-k8s-blueprints/examples/blob/main/stackit/main.tf) is that you activate DNS for your SKE cluster with a corresponding STACKIT dns zone.
You also need a STACKIT service account (for the Cert Manager webhook to perform the DNS01 challenge) with the permission for dns.admin or dns.editor. The Terraform bootstrapper will then create an access token for the service account, which will be used by the STACKIT Cert Manager webhook.

## Features:
- Installation of the base module(SKE)
- Bootstrapping gitops-ske-addons
  - STACKIT Secrets Manager Instance + User
  - NGINX Ingress Controller
  - Cert Manager + DNS01 and HTTP01 Let's Encrypt Issuer
  - STACKIT Cert Manager Webhook to execute 
  - Token creation for ServiceAccount/STACKIT Cert Manager Webhook and storing it into the STACKIT Secrets Manager

The STACKIT Cert Manager webhook receives the token via a secret created by the ExternalSecrets plugin. ExternalSecrets uses the corresponding Vault SecretsStore to work with the STACKIT Secret Manager.

## Usage
See the example implementation: [example folder](https://github.com/valiton-k8s-blueprints/examples/blob/main/stackit/main.tf)


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.17.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.36.0 |
| <a name="requirement_stackit"></a> [stackit](#requirement\_stackit) | ~> 0.55.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.36.0 |
| <a name="provider_stackit"></a> [stackit](#provider\_stackit) | ~> 0.55.0 |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |
| <a name="provider_vault"></a> [vault](#provider\_vault) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gitops_bridge_bootstrap"></a> [gitops\_bridge\_bootstrap](#module\_gitops\_bridge\_bootstrap) | git::https://github.com/valiton-k8s-blueprints/terraform-helm-gitops-bridge | main |

## Resources

| Name | Type |
|------|------|
| [kubernetes_namespace_v1.cert_manager_default_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/2.36.0/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.external_secrets](https://registry.terraform.io/providers/hashicorp/kubernetes/2.36.0/docs/resources/namespace_v1) | resource |
| [kubernetes_secret.vault_userpass_creds](https://registry.terraform.io/providers/hashicorp/kubernetes/2.36.0/docs/resources/secret) | resource |
| [stackit_service_account_access_token.cert_manager_sa_token](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/service_account_access_token) | resource |
| [time_rotating.rotate](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating) | resource |
| [vault_kv_secret_v2.cert_manager_webhook_secret](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kv_secret_v2) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addons"></a> [addons](#input\_addons) | Kubernetes addons | `any` | <pre>{<br/>  "enable_cert_manager": true,<br/>  "enable_cert_manager_default_cert": true,<br/>  "enable_external_secrets": true,<br/>  "enable_external_secrets_stackit_secrets_manager": true,<br/>  "enable_ingress_nginx": true,<br/>  "enable_kube_prometheus_stack": true<br/>}</pre> | no |
| <a name="input_cert_manager_acme_registration_email"></a> [cert\_manager\_acme\_registration\_email](#input\_cert\_manager\_acme\_registration\_email) | In cert-manager, the email address associated with an ACME account is used for administrative notifications and is included in the ACME configuration. | `string` | `"test@example.com"` | no |
| <a name="input_cert_manager_acme_stackit_project_id"></a> [cert\_manager\_acme\_stackit\_project\_id](#input\_cert\_manager\_acme\_stackit\_project\_id) | The STACKIT project id of the project in which the SKE cluster is running and the cert-manager is installed. | `string` | `null` | no |
| <a name="input_cert_manager_default_cert_domain_list"></a> [cert\_manager\_default\_cert\_domain\_list](#input\_cert\_manager\_default\_cert\_domain\_list) | When `enable_cert_manager_default_cert` is set to true, cert-manager will use these domains for the default certificate. | `list(any)` | <pre>[<br/>  "test.example.com",<br/>  "*.test.example.com"<br/>]</pre> | no |
| <a name="input_cert_manager_default_cert_name"></a> [cert\_manager\_default\_cert\_name](#input\_cert\_manager\_default\_cert\_name) | When `enable_cert_manager_default_cert` is set to true, cert-manager will use this name for the default certificate. | `string` | `"letsencrypt-default-cert"` | no |
| <a name="input_cert_manager_default_cert_namespace"></a> [cert\_manager\_default\_cert\_namespace](#input\_cert\_manager\_default\_cert\_namespace) | When `enable_cert_manager_default_cert` is set to true, the bootstrapper will create this namespace and the  cert-manager will put the default certificate into  this namespace. | `string` | `"myapp"` | no |
| <a name="input_cert_manager_default_cert_solver_type"></a> [cert\_manager\_default\_cert\_solver\_type](#input\_cert\_manager\_default\_cert\_solver\_type) | ACME challenge solver type for the default certificate | `string` | `"dns01"` | no |
| <a name="input_cert_manager_dns01_issuer_name"></a> [cert\_manager\_dns01\_issuer\_name](#input\_cert\_manager\_dns01\_issuer\_name) | The name of the issuer that ArgoCD should use to create the DNS01 challenge issuer. | `string` | `"letsencrypt-dns01"` | no |
| <a name="input_cert_manager_http01_issuer_name"></a> [cert\_manager\_http01\_issuer\_name](#input\_cert\_manager\_http01\_issuer\_name) | The name of the issuer that ArgoCD should use to create the http01 challenge issuer. | `string` | `"letsencrypt-http01"` | no |
| <a name="input_cert_manager_stackit_service_account_email"></a> [cert\_manager\_stackit\_service\_account\_email](#input\_cert\_manager\_stackit\_service\_account\_email) | The e-mail address for the STACKIT service account used by the Cert Manager (e.g. DNS01 challenge in the STACKIT dns zone). Note: The service account must exist beforehand and in the case of DNS01 Challenge it should also already have permission for dns.admin or dns.reader. | `string` | `"example@sa.stackit.cloud"` | no |
| <a name="input_cert_manager_stackit_webhook_service_account_secret"></a> [cert\_manager\_stackit\_webhook\_service\_account\_secret](#input\_cert\_manager\_stackit\_webhook\_service\_account\_secret) | The secret from the STACKIT service account, which includes the token to perform the DNS01 challenge in the configured STACKIT DNS zone. | `string` | `"certmanager/serviceaccount"` | no |
| <a name="input_cert_manager_use_default_cert"></a> [cert\_manager\_use\_default\_cert](#input\_cert\_manager\_use\_default\_cert) | When it is set to true, cert manager we use a default cert. | `bool` | `true` | no |
| <a name="input_custom_gitops_metadata"></a> [custom\_gitops\_metadata](#input\_custom\_gitops\_metadata) | This variable can be used to place additional meta information in the ArgoCD in-cluster secret. This information is then also available in the ApplicationSets via metadata.annotation. E.g.<br/><br/>custom\_gitops\_metadata = {<br/>  vault\_data\_db\_connection = vault\_kv\_secret\_v2.my\_db.path<br/>  vault\_data\_api\_key       = vault\_kv\_secret\_v2.api\_key.path<br/>} | `any` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Infrastructure environment name (e.g. development, staging, production). | `string` | `"development"` | no |
| <a name="input_external_secrets"></a> [external\_secrets](#input\_external\_secrets) | ExternalSecrets add-on configuration values | `any` | `{}` | no |
| <a name="input_external_secrets_stackit_secrets_manager_config"></a> [external\_secrets\_stackit\_secrets\_manager\_config](#input\_external\_secrets\_stackit\_secrets\_manager\_config) | Configuration parameters used by externalSecrets together with STACKIT secrets manager | `any` | `{}` | no |
| <a name="input_gitops_applications_repo_path"></a> [gitops\_applications\_repo\_path](#input\_gitops\_applications\_repo\_path) | Path in the Git repository for applications and values.yaml | `string` | `"stackit"` | no |
| <a name="input_gitops_applications_repo_revision"></a> [gitops\_applications\_repo\_revision](#input\_gitops\_applications\_repo\_revision) | Git repository revision/branch/ref for applications | `string` | `"main"` | no |
| <a name="input_gitops_applications_repo_url"></a> [gitops\_applications\_repo\_url](#input\_gitops\_applications\_repo\_url) | Url of Git repository for applications | `string` | `"https://github.com/valiton-k8s-blueprints/argocd"` | no |
| <a name="input_gitops_argocd_chart_version"></a> [gitops\_argocd\_chart\_version](#input\_gitops\_argocd\_chart\_version) | Initial ArgoCD helm chart version to be deployed via gitOps Bridge | `string` | `"8.0.17"` | no |
| <a name="input_kube_prometheus_stack"></a> [kube\_prometheus\_stack](#input\_kube\_prometheus\_stack) | Kube prometheus stack add-on configuration values | `any` | `{}` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | STACKIT project ID to which the cluster is associated. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | STACKIT region | `string` | `"eu01"` | no |
| <a name="input_ske_cluster_id"></a> [ske\_cluster\_id](#input\_ske\_cluster\_id) | Internal ID of the SKE cluster | `string` | n/a | yes |
| <a name="input_ske_cluster_name"></a> [ske\_cluster\_name](#input\_ske\_cluster\_name) | Name of the SKE cluster | `string` | n/a | yes |
| <a name="input_ske_cluster_version"></a> [ske\_cluster\_version](#input\_ske\_cluster\_version) | Kubernetes version to use for the SKE cluster | `string` | n/a | yes |
| <a name="input_ske_egress_adress_range"></a> [ske\_egress\_adress\_range](#input\_ske\_egress\_adress\_range) | Egress IP range of the clusters | `string` | n/a | yes |
| <a name="input_ske_nodepools"></a> [ske\_nodepools](#input\_ske\_nodepools) | Map of attribute maps for all SKE managed node pools. | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ske_gitops_bridge_metadata"></a> [ske\_gitops\_bridge\_metadata](#output\_ske\_gitops\_bridge\_metadata) | GitOps Bridge metadata |


## Best Practices
- Use **remote state storage** (e.g.ObjectStore or GitLab) to manage state files.
- Follow the **principle of least privilege** when defining STACKIT ServiceAccounts.

## Contributing
Feel free to submit **issues and pull requests** to improve this module.

## License
This module is licensed under the **MIT License**. See the [License](https://github.com/valiton/k8s-terraform-blueprints/blob/main/License)
