## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1 |
| <a name="requirement_stackit"></a> [stackit](#requirement\_stackit) | ~> 0.57.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_stackit"></a> [stackit](#provider\_stackit) | ~> 0.57.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [stackit_network.managed_cluster_network](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/network) | resource |
| [stackit_ske_cluster.managed_cluster](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/ske_cluster) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | Number of availability zones | `list(string)` | <pre>[<br/>  "eu01-1",<br/>  "eu01-2",<br/>  "eu01-3"<br/>]</pre> | no |
| <a name="input_base_name"></a> [base\_name](#input\_base\_name) | Name of your base infrastructure cluster. | `string` | `"my-project"` | no |
| <a name="input_base_node_pool_labels"></a> [base\_node\_pool\_labels](#input\_base\_node\_pool\_labels) | Labels of the base node group | `any` | <pre>{<br/>  "base_nodepool": "base"<br/>}</pre> | no |
| <a name="input_base_node_pool_machine_type"></a> [base\_node\_pool\_machine\_type](#input\_base\_node\_pool\_machine\_type) | List with instance types that are used in the base node group | `string` | `"c2i.2"` | no |
| <a name="input_base_node_pool_max_size"></a> [base\_node\_pool\_max\_size](#input\_base\_node\_pool\_max\_size) | Max instance count of the base node group | `number` | `3` | no |
| <a name="input_base_node_pool_max_surge"></a> [base\_node\_pool\_max\_surge](#input\_base\_node\_pool\_max\_surge) | Maximum number of additional VMs that are created during an update. If set (larger than 0), then it must be at least the amount of zones configured for the nodepool. The `max_surge` and `max_unavailable` fields cannot both be unset at the same time. | `number` | `3` | no |
| <a name="input_base_node_pool_max_unavailable"></a> [base\_node\_pool\_max\_unavailable](#input\_base\_node\_pool\_max\_unavailable) | Maximum number of VMs that that can be unavailable during an update. If set (larger than 0), then it must be at least the amount of zones configured for the nodepool. The `max_surge` and `max_unavailable` fields cannot both be unset at the same time. | `number` | `0` | no |
| <a name="input_base_node_pool_min_size"></a> [base\_node\_pool\_min\_size](#input\_base\_node\_pool\_min\_size) | Min instance count of the base node group | `number` | `2` | no |
| <a name="input_base_node_pool_os_name"></a> [base\_node\_pool\_os\_name](#input\_base\_node\_pool\_os\_name) | The name of the OS image. | `string` | `"flatcar"` | no |
| <a name="input_base_node_pool_volume_size"></a> [base\_node\_pool\_volume\_size](#input\_base\_node\_pool\_volume\_size) | The volume size in GB. | `number` | `20` | no |
| <a name="input_base_node_pool_volume_type"></a> [base\_node\_pool\_volume\_type](#input\_base\_node\_pool\_volume\_type) | Specifies the volume type. | `string` | `"storage_premium_perf1"` | no |
| <a name="input_create_network"></a> [create\_network](#input\_create\_network) | If the project is running within a STACKIT Network Area, the network in which the SKE Cluster should run must already exist. If set to true, a network is created and assigned to the SKE cluster and<pre>network_id</pre>will be ignored | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Infrastructure environment name (e.g. development, staging, production). | `string` | `"development"` | no |
| <a name="input_extensions_dns_enabled"></a> [extensions\_dns\_enabled](#input\_extensions\_dns\_enabled) | Flag to enable/disable DNS extensions. If set to `true`, SKE will then use an integrated version of externalDNS. | `bool` | `true` | no |
| <a name="input_extensions_dns_zones"></a> [extensions\_dns\_zones](#input\_extensions\_dns\_zones) | Specify a list of domain filters for externalDNS. | `list(string)` | <pre>[<br/>  "my-project.runs.onstackit.cloud"<br/>]</pre> | no |
| <a name="input_ipv4_nameservers"></a> [ipv4\_nameservers](#input\_ipv4\_nameservers) | The IPv4 nameservers of the network. | `list(string)` | <pre>[<br/>  "9.9.9.9",<br/>  "1.1.1.1"<br/>]</pre> | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version | `string` | `"1.31"` | no |
| <a name="input_maintenance_enable_kubernetes_version_updates"></a> [maintenance\_enable\_kubernetes\_version\_updates](#input\_maintenance\_enable\_kubernetes\_version\_updates) | Flag to enable/disable auto-updates of the Kubernetes version. SKE automatically updates the cluster Kubernetes version if you have set `maintenance.enable_kubernetes_version_updates` to true or if there is a mandatory update. | `bool` | `true` | no |
| <a name="input_maintenance_enable_machine_image_version_updates"></a> [maintenance\_enable\_machine\_image\_version\_updates](#input\_maintenance\_enable\_machine\_image\_version\_updates) | Flag to enable/disable auto-updates of the OS image version. | `bool` | `true` | no |
| <a name="input_maintenance_end"></a> [maintenance\_end](#input\_maintenance\_end) | Time for maintenance window end. | `string` | `"02:00:00Z"` | no |
| <a name="input_maintenance_start"></a> [maintenance\_start](#input\_maintenance\_start) | Time for maintenance window start. | `string` | `"01:00:00Z"` | no |
| <a name="input_network_id"></a> [network\_id](#input\_network\_id) | The network id of the network in which the SKE Cluster should run, in case the project is running within a STACKIT Network Area. This can only be used if the project is running within an STACKIT Network Area. | `string` | `null` | no |
| <a name="input_network_ipv4_prefix_length"></a> [network\_ipv4\_prefix\_length](#input\_network\_ipv4\_prefix\_length) | The IPv4 prefix length of the network. | `number` | `25` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | STACKIT project ID to which the cluster is associated. | `string` | n/a | yes |
| <a name="input_ske_managed_node_pools"></a> [ske\_managed\_node\_pools](#input\_ske\_managed\_node\_pools) | SKE managed nodepools in addition to the base nodepool | `any` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_egress_address_range"></a> [cluster\_egress\_address\_range](#output\_cluster\_egress\_address\_range) | The outgoing network ranges (in CIDR notation) of traffic originating from workload on the cluster. |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | Terraform's internal resource ID. It is structured as `project_id`,`region`,`name`. |
| <a name="output_cluster_kubernetes_version_used"></a> [cluster\_kubernetes\_version\_used](#output\_cluster\_kubernetes\_version\_used) | Full Kubernetes version used. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the SKE Cluster. |
| <a name="output_cluster_nodepools"></a> [cluster\_nodepools](#output\_cluster\_nodepools) | Defined nodepools fot the SKE cluster |
