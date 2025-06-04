# Terraform AWS Base Module

## Overview
This Terraform module sets up foundational AWS infrastructure, providing a base for deploying workloads on AWS. It follows best practices to ensure security, scalability, and maintainability.

## Features
- Creates a **VPC** with public and private subnets
- Creates an **EKS** cluster
- Configures **IAM roles and policies**
- Deploys **EC2 instances, security groups, and networking components** that are required to run the tooling services

This setup does not contain any application specific requirements. It focuses simply on Layer 1 that contains the VPC and EKS. 

## Usage
To use this module, include the following in your Terraform configuration:

```hcl
module "base" {
  source = "git::git@github.com:valiton/k8s-terraform-blueprints.git//terraform/cloud-provider/aws/base?ref=main"
  
  base_name = "my_project"
  
  # Additional configuration...
}
```
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.97.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.97.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ebs_csi_driver_irsa"></a> [ebs\_csi\_driver\_irsa](#module\_ebs\_csi\_driver\_irsa) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | 5.55.0 |
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 20.36.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 5.21.0 |

## Resources

| Name | Type |
|------|------|
| [random_integer.ip_part](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/5.97.0/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azs_count"></a> [azs\_count](#input\_azs\_count) | Number of availability zones | `number` | `2` | no |
| <a name="input_base_name"></a> [base\_name](#input\_base\_name) | Name of your base infrastructure. | `string` | `"my-project"` | no |
| <a name="input_base_node_group_ami_type"></a> [base\_node\_group\_ami\_type](#input\_base\_node\_group\_ami\_type) | AMI type used by the base node group | `string` | `"AL2023_ARM_64_STANDARD"` | no |
| <a name="input_base_node_group_capacity_type"></a> [base\_node\_group\_capacity\_type](#input\_base\_node\_group\_capacity\_type) | Capacity types used by the base node group | `string` | `"ON_DEMAND"` | no |
| <a name="input_base_node_group_desired_size"></a> [base\_node\_group\_desired\_size](#input\_base\_node\_group\_desired\_size) | Initial desired instance count of the base node group | `number` | `2` | no |
| <a name="input_base_node_group_instance_types"></a> [base\_node\_group\_instance\_types](#input\_base\_node\_group\_instance\_types) | List with instance types that are used in the base node group | `list(string)` | <pre>[<br/>  "t4g.medium"<br/>]</pre> | no |
| <a name="input_base_node_group_labels"></a> [base\_node\_group\_labels](#input\_base\_node\_group\_labels) | Labels of the base node group | `any` | <pre>{<br/>  "base_nodepool": "base"<br/>}</pre> | no |
| <a name="input_base_node_group_max_size"></a> [base\_node\_group\_max\_size](#input\_base\_node\_group\_max\_size) | Max instance count of the base node group | `number` | `3` | no |
| <a name="input_base_node_group_min_size"></a> [base\_node\_group\_min\_size](#input\_base\_node\_group\_min\_size) | Min instance count of the base node group | `number` | `1` | no |
| <a name="input_cloudwatch_log_group_class"></a> [cloudwatch\_log\_group\_class](#input\_cloudwatch\_log\_group\_class) | Specified the log class of the log group. Possible values are: `STANDARD` or `INFREQUENT_ACCESS` | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_retention_in_days"></a> [cloudwatch\_log\_group\_retention\_in\_days](#input\_cloudwatch\_log\_group\_retention\_in\_days) | Number of days to retain log events. | `number` | `30` | no |
| <a name="input_cluster_enabled_log_types"></a> [cluster\_enabled\_log\_types](#input\_cluster\_enabled\_log\_types) | List of the desired control plane logs to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html) Example: `[ "audit", "api", "authenticator" ]` | `list` | `[]` | no |
| <a name="input_create_cloudwatch_log_group"></a> [create\_cloudwatch\_log\_group](#input\_create\_cloudwatch\_log\_group) | Determines whether a log group is created by this module for the cluster logs. If not, AWS will automatically create one if logging is enabled | `bool` | `false` | no |
| <a name="input_eks_managed_node_groups"></a> [eks\_managed\_node\_groups](#input\_eks\_managed\_node\_groups) | EKS managed nodegroups in addition to the base nodegroup | `any` | `{}` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Infrastructure environment name (e.g. development, staging, production). | `string` | `"development"` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version | `string` | `"1.32"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"eu-central-1"` | no |
| <a name="input_single_nat_gateway"></a> [single\_nat\_gateway](#input\_single\_nat\_gateway) | True if only a single NAT gateway should be deployed instead of one per AZ | `bool` | `false` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC CIDR, if empty a random CIDR will be chosen | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | Base64 encoded certificate data required to communicate with the cluster. |
| <a name="output_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#output\_eks\_cluster\_endpoint) | Endpoint for your Kubernetes API server |
| <a name="output_eks_cluster_name"></a> [eks\_cluster\_name](#output\_eks\_cluster\_name) | The name of the EKS cluster |
| <a name="output_eks_cluster_version"></a> [eks\_cluster\_version](#output\_eks\_cluster\_version) | Kubernetes `<major>.<minor>` version. |
| <a name="output_eks_managed_node_groups"></a> [eks\_managed\_node\_groups](#output\_eks\_managed\_node\_groups) | List of managed nodegroups in the cluster |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | The ARN of the cluster OIDC Provider. |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | The CIDR block of the VPC |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
| <a name="output_vpc_private_subnets"></a> [vpc\_private\_subnets](#output\_vpc\_private\_subnets) | List of IDs of private subnets |
| <a name="output_vpc_private_subnets_cidr_blocks"></a> [vpc\_private\_subnets\_cidr\_blocks](#output\_vpc\_private\_subnets\_cidr\_blocks) | List of cidr\_blocks of private subnets |
| <a name="output_vpc_public_subnets"></a> [vpc\_public\_subnets](#output\_vpc\_public\_subnets) | List of IDs of public subnets |
| <a name="output_vpc_public_subnets_cidr_blocks"></a> [vpc\_public\_subnets\_cidr\_blocks](#output\_vpc\_public\_subnets\_cidr\_blocks) | List of cidr\_blocks of public subnets |

## Best Practices
- Use **remote state storage** (e.g., S3 + DynamoDB) to manage state files.
- Follow the **principle of least privilege** when defining IAM roles.
- Enable **logging and monitoring** with AWS CloudWatch and GuardDuty.

## Contributing
Feel free to submit **issues and pull requests** to improve this module.

## License
This module is licensed under the **MIT License**. See the [License](../../../License) file for details.
