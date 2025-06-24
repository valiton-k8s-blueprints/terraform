# Terraform STACKIT Base Module

## Overview
This Terraform module sets up a STACKIT SKE cluster, providing a base for deploying workloads on STACKIT. It follows best practices to ensure security, scalability, and maintainability.

## Features
- Creates a **virtual Network**
- Creates a **SKE** cluster
- Configures **externalDNS** as extension
- Deploys predefined **Nodepools**

## Usage
See the example implementation: [example folder](https://github.com/valiton-k8s-blueprints/examples/blob/main/stackit/main.tf)


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1 |
| <a name="requirement_stackit"></a> [stackit](#requirement\_stackit) | ~> 0.55.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_stackit"></a> [stackit](#provider\_stackit) | ~> 0.55.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [stackit_ske_cluster.managed_cluster](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/ske_cluster) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | Number of availability zones | `list(string)` | <pre>[<br/>  "eu01-1",<br/>  "eu01-2",<br/>  "eu01-3",<br/>  "eu01-m"<br/>]</pre> | no |
| <a name="input_base_name"></a> [base\_name](#input\_base\_name) | Name of your base infrastructure cluster. | `string` | `"my-project"` | no |
| <a name="input_base_node_pool_labels"></a> [base\_node\_pool\_labels](#input\_base\_node\_pool\_labels) | Labels of the base node group | `any` | <pre>{<br/>  "base_nodepool": "base"<br/>}</pre> | no |
| <a name="input_base_node_pool_machine_type"></a> [base\_node\_pool\_machine\_type](#input\_base\_node\_pool\_machine\_type) | List with instance types that are used in the base node group | `string` | `"c1.2"` | no |
| <a name="input_base_node_pool_max_size"></a> [base\_node\_pool\_max\_size](#input\_base\_node\_pool\_max\_size) | Max instance count of the base node group | `number` | `3` | no |
| <a name="input_base_node_pool_max_surge"></a> [base\_node\_pool\_max\_surge](#input\_base\_node\_pool\_max\_surge) | Maximum number of additional VMs that are created during an update. If set (larger than 0), then it must be at least the amount of zones configured for the nodepool. The `max_surge` and `max_unavailable` fields cannot both be unset at the same time. | `number` | `2` | no |
| <a name="input_base_node_pool_max_unavailable"></a> [base\_node\_pool\_max\_unavailable](#input\_base\_node\_pool\_max\_unavailable) | Maximum number of VMs that that can be unavailable during an update. If set (larger than 0), then it must be at least the amount of zones configured for the nodepool. The `max_surge` and `max_unavailable` fields cannot both be unset at the same time. | `number` | `0` | no |
| <a name="input_base_node_pool_min_size"></a> [base\_node\_pool\_min\_size](#input\_base\_node\_pool\_min\_size) | Min instance count of the base node group | `number` | `2` | no |
| <a name="input_base_node_pool_os_name"></a> [base\_node\_pool\_os\_name](#input\_base\_node\_pool\_os\_name) | The name of the OS image. | `string` | `"flatcar"` | no |
| <a name="input_base_node_pool_volume_size"></a> [base\_node\_pool\_volume\_size](#input\_base\_node\_pool\_volume\_size) | The volume size in GB. | `number` | `20` | no |
| <a name="input_base_node_pool_volume_type"></a> [base\_node\_pool\_volume\_type](#input\_base\_node\_pool\_volume\_type) | Specifies the volume type. | `string` | `"storage_premium_perf1"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Infrastructure environment name (e.g. development, staging, production). | `string` | `"development"` | no |
| <a name="input_extensions_dns_enabled"></a> [extensions\_dns\_enabled](#input\_extensions\_dns\_enabled) | Flag to enable/disable DNS extensions. If set to `true`, SKE will then use an integrated version of externalDNS. | `bool` | `true` | no |
| <a name="input_extensions_dns_zones"></a> [extensions\_dns\_zones](#input\_extensions\_dns\_zones) | Specify a list of domain filters for externalDNS. | `list(string)` | <pre>[<br/>  "my-project.runs.onstackit.cloud"<br/>]</pre> | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version | `string` | `"1.31"` | no |
| <a name="input_maintenance_enable_kubernetes_version_updates"></a> [maintenance\_enable\_kubernetes\_version\_updates](#input\_maintenance\_enable\_kubernetes\_version\_updates) | Flag to enable/disable auto-updates of the Kubernetes version. SKE automatically updates the cluster Kubernetes version if you have set `maintenance.enable_kubernetes_version_updates` to true or if there is a mandatory update. | `bool` | `true` | no |
| <a name="input_maintenance_enable_machine_image_version_updates"></a> [maintenance\_enable\_machine\_image\_version\_updates](#input\_maintenance\_enable\_machine\_image\_version\_updates) | Flag to enable/disable auto-updates of the OS image version. | `bool` | `true` | no |
| <a name="input_maintenance_end"></a> [maintenance\_end](#input\_maintenance\_end) | Time for maintenance window end. | `string` | `"02:00:00Z"` | no |
| <a name="input_maintenance_start"></a> [maintenance\_start](#input\_maintenance\_start) | Time for maintenance window start. | `string` | `"01:00:00Z"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | STACKIT project ID to which the cluster is associated. | `string` | n/a | yes |
| <a name="input_ske_managed_node_pools"></a> [ske\_managed\_node\_pools](#input\_ske\_managed\_node\_pools) | SKE managed nodepools in addition to the base nodepool | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_egress_address_range"></a> [cluster\_egress\_address\_range](#output\_cluster\_egress\_address\_range) | The outgoing network ranges (in CIDR notation) of traffic originating from workload on the cluster. |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | Terraform's internal resource ID. It is structured as `project_id`,`region`,`name`. |
| <a name="output_cluster_kubernetes_version_used"></a> [cluster\_kubernetes\_version\_used](#output\_cluster\_kubernetes\_version\_used) | Full Kubernetes version used. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the SKE Cluster. |
| <a name="output_cluster_nodepools"></a> [cluster\_nodepools](#output\_cluster\_nodepools) | Defined nodepools fot the SKE cluster |

## Best Practices
- Use **remote state storage** (e.g.ObjectStore or GitLab) to manage state files.
- Follow the **principle of least privilege** when defining STACKIT ServiceAccounts.

## Contributing
Feel free to submit **issues and pull requests** to improve this module.

## License
This module is licensed under the **MIT License**. See the [License](https://github.com/valiton/k8s-terraform-blueprints/blob/main/License)
