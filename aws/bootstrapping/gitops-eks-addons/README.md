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

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/5.97.0/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addons"></a> [addons](#input\_addons) | Kubernetes addons | `any` | <pre>{<br/>  "enable_aws_ebs_csi_resources": true,<br/>  "enable_aws_efs_csi_driver": true,<br/>  "enable_aws_load_balancer_controller": true,<br/>  "enable_external_dns": true,<br/>  "enable_external_secrets": true,<br/>  "enable_karpenter": true,<br/>  "enable_kube_prometheus_stack": true,<br/>  "enable_metrics_server": true<br/>}</pre> | no |
| <a name="input_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#input\_eks\_cluster\_endpoint) | Base module dependency: Endpoint for your Kubernetes API server | `string` | n/a | yes |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | Base module dependency: Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_eks_cluster_version"></a> [eks\_cluster\_version](#input\_eks\_cluster\_version) | Base module dependency: Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.32`) created from the base module | `string` | n/a | yes |
| <a name="input_eks_image_arm64"></a> [eks\_image\_arm64](#input\_eks\_image\_arm64) | Karpenter: Recommended Amazon Linux AMI ID for AL2023 ARM instances. | `string` | `"ami-09b9ca376adb3607c"` | no |
| <a name="input_eks_image_x86_64"></a> [eks\_image\_x86\_64](#input\_eks\_image\_x86\_64) | Karpenter: Recommended Amazon Linux AMI ID for AL2023 x86 based instances. | `string` | `"ami-0239e3e7b036949c1"` | no |
| <a name="input_eks_managed_node_groups"></a> [eks\_managed\_node\_groups](#input\_eks\_managed\_node\_groups) | Base module dependency: Map of attribute maps for all EKS managed node groups created from the base module. | `any` | n/a | yes |
| <a name="input_eks_oidc_provider_arn"></a> [eks\_oidc\_provider\_arn](#input\_eks\_oidc\_provider\_arn) | Base module dependency: The ARN of the cluster OIDC Provider created from the base module | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Infrastructure environment name (e.g. development, staging, production). | `string` | `"development"` | no |
| <a name="input_external_dns_domain_filters"></a> [external\_dns\_domain\_filters](#input\_external\_dns\_domain\_filters) | Limit possible target zones by domain suffixes. | `string` | `"['example.org']"` | no |
| <a name="input_gitops_addons_org"></a> [gitops\_addons\_org](#input\_gitops\_addons\_org) | Git repository org/user contains for addons | `string` | `"https://github.com/valiton"` | no |
| <a name="input_gitops_addons_repo"></a> [gitops\_addons\_repo](#input\_gitops\_addons\_repo) | Git repository contains for addons | `string` | `"k8s-terraform-blueprints"` | no |
| <a name="input_gitops_addons_revision"></a> [gitops\_addons\_revision](#input\_gitops\_addons\_revision) | Git repository revision/branch/ref for addons | `string` | `"main"` | no |
| <a name="input_gitops_oss_addon_config_path"></a> [gitops\_oss\_addon\_config\_path](#input\_gitops\_oss\_addon\_config\_path) | Git repository path for oss addon configurations | `string` | `"argocd/addons/config/oss"` | no |
| <a name="input_gitops_oss_addons_basepath"></a> [gitops\_oss\_addons\_basepath](#input\_gitops\_oss\_addons\_basepath) | Git repository base path for oss addons | `string` | `"argocd/addons/"` | no |
| <a name="input_gitops_oss_addons_path"></a> [gitops\_oss\_addons\_path](#input\_gitops\_oss\_addons\_path) | Git repository path for oss addons | `string` | `"oss"` | no |
| <a name="input_gitops_oss_workload_basepath"></a> [gitops\_oss\_workload\_basepath](#input\_gitops\_oss\_workload\_basepath) | Git repository base path for oss addon resources | `string` | `"addon-dependent-resources/"` | no |
| <a name="input_gitops_oss_workload_path"></a> [gitops\_oss\_workload\_path](#input\_gitops\_oss\_workload\_path) | Git repository path for oss addon resources | `string` | `"oss"` | no |
| <a name="input_gitops_vendor_addon_config_path"></a> [gitops\_vendor\_addon\_config\_path](#input\_gitops\_vendor\_addon\_config\_path) | Git repository path for vendor specific addon configurations | `string` | `"argocd/addons/config/vendors/aws"` | no |
| <a name="input_gitops_vendor_addons_basepath"></a> [gitops\_vendor\_addons\_basepath](#input\_gitops\_vendor\_addons\_basepath) | Git repository base path for vendor specific addons | `string` | `"argocd/addons/vendors/"` | no |
| <a name="input_gitops_vendor_addons_path"></a> [gitops\_vendor\_addons\_path](#input\_gitops\_vendor\_addons\_path) | Git repository path for vendor specific addons | `string` | `"aws"` | no |
| <a name="input_gitops_vendor_workload_basepath"></a> [gitops\_vendor\_workload\_basepath](#input\_gitops\_vendor\_workload\_basepath) | Git repository base path for vendor specific addon resources | `string` | `"addon-dependent-resources/vendors/"` | no |
| <a name="input_gitops_vendor_workload_path"></a> [gitops\_vendor\_workload\_path](#input\_gitops\_vendor\_workload\_path) | Git repository path for vendor specific addon resources | `string` | `"aws"` | no |
| <a name="input_gitops_workload_org"></a> [gitops\_workload\_org](#input\_gitops\_workload\_org) | Git repository org/user contains for workload | `string` | `"https://github.com/valiton"` | no |
| <a name="input_gitops_workload_repo"></a> [gitops\_workload\_repo](#input\_gitops\_workload\_repo) | Git repository contains for workload | `string` | `"k8s-terraform-blueprints"` | no |
| <a name="input_gitops_workload_revision"></a> [gitops\_workload\_revision](#input\_gitops\_workload\_revision) | Git repository revision/branch/ref for workload | `string` | `"main"` | no |
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
