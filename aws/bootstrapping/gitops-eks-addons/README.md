# Terraform AWS Gitops EKS Addons Module

## Overview
This plugin is based on the concept of Gitops-Bridge. This means that the EKS plugins are not deployed into the cluster via Terraform, but only their required AWS resources such as IAM roles etc. are created. The actual plugins are rolled out using the gitOps approach with Argo CD.

## Prerequisite
This module is an addon. This means that the base module should be installed beforehand.
See the example implementation: [example folder](../../examples/README.md#base-module--gitops-eks-addons)

## Features
- Installs all AWS resources that are required by the enabled addons
- Installs an intial deployment of argocd, this deployment (gets replaced by argocd applicationset)
- Creates the ArgoCD cluster secret (including in-cluster)
- Creates the intial set App of Apps (addons, workloads, etc.)

## Usage
See the example implementation: [example folder](../../examples/README.md#base-module--gitops-eks-addons)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.97.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.17.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.36.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.97.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_auth"></a> [aws\_auth](#module\_aws\_auth) | terraform-aws-modules/eks/aws//modules/aws-auth | n/a |
| <a name="module_eks_blueprints_addons"></a> [eks\_blueprints\_addons](#module\_eks\_blueprints\_addons) | aws-ia/eks-blueprints-addons/aws | 1.21.0 |
| <a name="module_gitops_bridge_bootstrap"></a> [gitops\_bridge\_bootstrap](#module\_gitops\_bridge\_bootstrap) | git::https://github.com/valiton-k8s-blueprints/terraform-helm-gitops-bridge | main |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.97.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.17.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.36.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.97.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_auth"></a> [aws\_auth](#module\_aws\_auth) | terraform-aws-modules/eks/aws//modules/aws-auth | n/a |
| <a name="module_eks_blueprints_addons"></a> [eks\_blueprints\_addons](#module\_eks\_blueprints\_addons) | aws-ia/eks-blueprints-addons/aws | 1.21.0 |
| <a name="module_gitops_bridge_bootstrap"></a> [gitops\_bridge\_bootstrap](#module\_gitops\_bridge\_bootstrap) | git::https://github.com/valiton-k8s-blueprints/terraform-helm-gitops-bridge | main |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/5.97.0/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addons"></a> [addons](#input\_addons) | Kubernetes addons | `any` | <pre>{<br/>  "enable_aws_ebs_csi_resources": true,<br/>  "enable_aws_efs_csi_driver": true,<br/>  "enable_aws_load_balancer_controller": true,<br/>  "enable_cert_manager": false,<br/>  "enable_cert_manager_issuers": false,<br/>  "enable_external_dns": true,<br/>  "enable_external_secrets": true,<br/>  "enable_ingress_nginx": false,<br/>  "enable_karpenter": true,<br/>  "enable_kube_prometheus_stack": true,<br/>  "enable_metrics_server": true<br/>}</pre> | no |
| <a name="input_custom_gitops_metadata"></a> [custom\_gitops\_metadata](#input\_custom\_gitops\_metadata) | This variable can be used to place additional meta information in the ArgoCD in-cluster secret. This information is then also available in the ApplicationSets via metadata.annotation. E.g.<br/><br/>custom\_gitops\_metadata = {<br/>  ssm\_parameter\_db\_connection = "/MYAPP/DB\_CONNECTION\_STRING" <br/>  ssm\_parameter\_api\_key = "/MYAPP/API\_KEY"<br/>} | `any` | `null` | no |
| <a name="input_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#input\_eks\_cluster\_endpoint) | Base module dependency: Endpoint for your Kubernetes API server | `string` | n/a | yes |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | Base module dependency: Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_eks_cluster_version"></a> [eks\_cluster\_version](#input\_eks\_cluster\_version) | Base module dependency: Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.32`) created from the base module | `string` | n/a | yes |
| <a name="input_eks_image_arm64"></a> [eks\_image\_arm64](#input\_eks\_image\_arm64) | Karpenter: Recommended Amazon Linux AMI ID for AL2023 ARM instances. | `string` | `"ami-03346acdd644443a9"` | no |
| <a name="input_eks_image_x86_64"></a> [eks\_image\_x86\_64](#input\_eks\_image\_x86\_64) | Karpenter: Recommended Amazon Linux AMI ID for AL2023 x86 based instances. | `string` | `"ami-04f94cfef8368f0e4"` | no |
| <a name="input_eks_managed_node_groups"></a> [eks\_managed\_node\_groups](#input\_eks\_managed\_node\_groups) | Base module dependency: Map of attribute maps for all EKS managed node groups created from the base module. | `any` | n/a | yes |
| <a name="input_eks_oidc_provider_arn"></a> [eks\_oidc\_provider\_arn](#input\_eks\_oidc\_provider\_arn) | Base module dependency: The ARN of the cluster OIDC Provider created from the base module | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Infrastructure environment name (e.g. development, staging, production). | `string` | `"development"` | no |
| <a name="input_external_dns_domain_filters"></a> [external\_dns\_domain\_filters](#input\_external\_dns\_domain\_filters) | Limit possible target zones by domain suffixes. | `string` | `"['example.org']"` | no |
| <a name="input_gitops_applications_repo_path"></a> [gitops\_applications\_repo\_path](#input\_gitops\_applications\_repo\_path) | Path in the Git repository for applications and values.yaml | `string` | `"aws"` | no |
| <a name="input_gitops_applications_repo_revision"></a> [gitops\_applications\_repo\_revision](#input\_gitops\_applications\_repo\_revision) | Git repository revision/branch/ref for applications | `string` | `"main"` | no |
| <a name="input_gitops_applications_repo_url"></a> [gitops\_applications\_repo\_url](#input\_gitops\_applications\_repo\_url) | Url of Git repository for applications | `string` | `"https://github.com/valiton-k8s-blueprints/argocd"` | no |
| <a name="input_gitops_argocd_chart_version"></a> [gitops\_argocd\_chart\_version](#input\_gitops\_argocd\_chart\_version) | Initial ArgoCD helm chart version to be deployed via gitOps Bridge | `string` | `"8.0.17"` | no |
| <a name="input_kube_prometheus_stack"></a> [kube\_prometheus\_stack](#input\_kube\_prometheus\_stack) | Kube prometheus stack add-on configuration values | `any` | `{}` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"eu-central-1"` | no |
| <a name="input_route53_zone"></a> [route53\_zone](#input\_route53\_zone) | Limit possible route53 zones. | `string` | `"*"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | Base module dependency: ID of the VPC where the cluster security group will be provisioned | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eks_gitops_bridge_metadata"></a> [eks\_gitops\_bridge\_metadata](#output\_eks\_gitops\_bridge\_metadata) | GitOps Bridge metadata |
| <a name="output_x_access_argocd"></a> [x\_access\_argocd](#output\_x\_access\_argocd) | ArgoCD Access |
| <a name="output_x_configure_argocd"></a> [x\_configure\_argocd](#output\_x\_configure\_argocd) | Terminal Setup |
| <a name="output_x_configure_kubectl"></a> [x\_configure\_kubectl](#output\_x\_configure\_kubectl) | Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig |
