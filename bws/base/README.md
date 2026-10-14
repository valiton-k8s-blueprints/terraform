# Terraform BWS Base Module

## Overview
This Terraform module sets up foundational BWS infrastructure, providing a base for deploying workloads on BWS. It follows best practices to ensure security, scalability, and maintainability.

## Features
- Creates network infrastructure
- Creates a Kubernets cluster with Talos

## Usage
To use this module, include the following in your Terraform configuration:

```hcl
module "base" {
  source = "git::git@github.com:valiton-k8s-blueprints/terraform.git/bws-talos/base?ref=main"

  base_name = "my_project"

  # Additional configuration...
}
```

## Before you start
This setup uses [Talos Linux](https://www.talos.dev/) to deploy and run Kubernetes. To manage Talos you have to install talosctl
on the machine that runs the setup. Get the version for your platform with Homebrew or download it from https://github.com/siderolabs/talos/releases.

You also need a BWS project that is available via UCS. Log into BWS and create application credentials with roles "reader", "member" and "load-balancer_member".
Secondly create a floating ip address that will be used as the endpoint to access Talos and Kubernetes.

Setup your terraform configuration (see examples) and create Talos secrets with the command

```shell
talosctl gen secrets
```

Setup the terraform variables for

```terraform
os_application_credential_id     = "<your application credential id>"
os_application_credential_secret = "<your application credential secret>"
kube_api_external_ip             = "<your floating ip>"
```

Plan and apply.

Once the terraform run ends successful, get your talosconfig and kubeconfig. Store the generated secrets.yaml in a save place
since it is your key to the cluster in case you loose your talosconfig.

You should also retrieve and store in a save place the talos configuration for controlplanes and workers if you want to scale up
the cluster

```shell
terraform output -raw controlplane_machine_configuration > controlplane.yaml
terraform output -raw worker_machine_configuration > worker.yaml
```

## Private network configuration

Omit `os_existing_private_network` (or set it to `null`) to create a private
network, subnet, router, and router interface. `os_private_network_name` names
the created network, prefixed with `base_name`. The optional
`os_private_network_subnet_name` overrides the created subnet's name; otherwise
it is derived from `base_name` and `os_private_network_name`.
`os_private_network_cidr` sets the created subnet's IPv4 CIDR; leaving it empty
generates a CIDR.

To reuse networking, supply the exact existing network and subnet names:

```hcl
os_existing_private_network = {
  network_name = "shared-private-network"
  subnet_name  = "shared-private-subnet"
}
```

Both object fields must be non-null and nonblank. Partial or invalid objects
are errors, not requests to create networking. The subnet must belong to the
selected network and use IPv4. Missing or ambiguous lookups fail; the module
never falls back to creating networking. Leave `os_private_network_cidr` empty
when reusing a subnet; the module exports the selected subnet's actual CIDR.
The object must be supplied as a plan-time-known value because its presence
determines whether Terraform creates networking.

Reused networking must already have the required routing and connectivity;
the module does not manage its network, subnet, router, or router interface.
Cluster-specific ports, security groups, and API load balancing remain managed
in both cases. `os_private_network_name` remains required and also participates
in cluster-specific security-group naming, even when the lookup names come
from the object.

For additional rules in the cluster's internal security group, reference
`module.base.internal_security_group_id` directly. This preserves the resource
dependency without a name lookup or a whole-module `depends_on`, which can defer
the lookup and unnecessarily replace rules when unrelated base resources change.

### Migrating from the mode selector

`os_private_network_mode` has been removed. For previously managed networking,
remove the `managed` selector and retain the current naming and CIDR inputs.
For previously existing networking, move the exact lookup names from
`os_private_network_name` and `os_private_network_subnet_name` into
`os_existing_private_network` and remove the `existing` selector. Retain
`os_private_network_name` to preserve cluster-specific security-group names;
`os_private_network_subnet_name` now only controls created-subnet naming.

Changing an already managed deployment to reuse is **not** an ownership/state
migration: Terraform may plan to destroy the formerly managed resources.
Review the plan and deliberately transfer state ownership before applying.
Do not apply a plan that destroys networking you intend to keep.

### Testing

From `bws/base/modules/network`, run `tofu init -backend=false` and `tofu test`.
The focused tests use mocked providers and plan-only runs, including checks for
managed/existing networking, selected subnet usage, security-group outputs, and
invalid inputs. They require a runner supporting provider mocks and have been
verified with OpenTofu 1.13.1. They do not apply real infrastructure; actual
missing or ambiguous OpenStack lookups require separate provider-backed
verification.

## Requirements

## Best Practices
- Use **remote state storage** (e.g., S3 + DynamoDB) to manage state files.
- Follow the **principle of least privilege**

## Contributing
Feel free to submit **issues and pull requests** to improve this module.

## License
This module is licensed under the **MIT License**.