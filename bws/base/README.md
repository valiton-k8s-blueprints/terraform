# Local BWS Base Module

Runtime source derived from `bws/base` at `v1.1.0` in
https://github.com/valiton-k8s-blueprints/terraform.

The local changes add `os_private_network_mode` (`managed` or `existing`) and
`os_private_network_subnet_name`, move managed CIDR generation into the network
submodule, and expose the selected subnet's actual CIDR. Existing mode only reads
shared networking; managed mode preserves upstream network creation and naming
defaults. Cluster-specific ports, security groups and API load balancing remain
managed in both modes.

Both Talos configuration generators are pinned to the existing `v1.13` contract
so provider `0.12.0` fixes inconsistent plans without changing SDK-selected
configuration defaults. The Talos client-key output is explicitly sensitive.
Five `moved` declarations preserve the upstream resource addresses when the
parent selects this local module: the random CIDR moves into the network module,
and managed network/subnet/router/interface addresses gain index `[0]`.

The root forwards networking inputs from local values; the deployed cluster uses
existing mode. Switching modes on populated state can replace node boot disks and
destroy the old etcd state, so it requires a reviewed clean-redeployment plan.

Bootstrap has a VM-identity replacement trigger and an identity-keyed readiness
check. The provider's bootstrap Update is a state-only operation; a replacement
cluster must run Create to initialize etcd. This mechanism is for clean cluster
replacement, not rolling control-plane replacement in a surviving etcd cluster.
See the infrastructure README before changing that mode or publishing these
module changes upstream.

All referenced distribution submodules and templates are retained so OpenTofu can
resolve the original module tree. The cluster uses Talos; the other distribution
implementations are unchanged. See the infrastructure README for configuration
and the network submodule's `tests/network_modes.tftest.hcl` and Talos configuration
submodule's `tests/config_contract.tftest.hcl` for plan-only tests.