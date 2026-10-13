mock_provider "random" {
  mock_resource "random_integer" {
    defaults = {
      result = 160
    }
  }
}

mock_provider "openstack" {
  mock_data "openstack_networking_network_v2" {
    defaults = {
      id = "existing-network-id"
    }
  }

  mock_data "openstack_networking_subnet_v2" {
    defaults = {
      id   = "existing-subnet-id"
      cidr = "172.20.40.0/24"
    }
  }

  mock_resource "openstack_networking_network_v2" {
    defaults = {
      id = "managed-network-id"
    }
  }

  mock_resource "openstack_networking_subnet_v2" {
    defaults = {
      id = "managed-subnet-id"
    }
  }

  mock_resource "openstack_networking_port_v2" {
    defaults = {
      all_fixed_ips = ["172.20.40.10"]
    }
  }
}

variables {
  name_prefix                    = "test-cluster"
  os_public_network_name         = "Public1"
  os_private_network_name        = "Net_VALTION-BURDAVERLAG"
  os_private_network_subnet_name = "Subnet_VALTION-BURDAVERLAG"
  os_private_network_mode        = "existing"
  kube_api_external_ip           = "192.0.2.10"
  kube_api_external_port         = 6443
  keystone_auth_port             = 30043
  worker_count                   = 2
  controlplane_count             = 3
  enable_talos_api               = true
  enable_ssh_bastion             = false
  enable_k0s_api                 = false
  enable_konnectivity            = false
  enable_keystone_auth           = true
}

run "existing_network" {
  command = plan

  assert {
    condition = (
      length(openstack_networking_network_v2.private_network) == 0 &&
      length(openstack_networking_subnet_v2.private_network_subnet) == 0 &&
      length(openstack_networking_router_v2.private_network_router) == 0 &&
      length(openstack_networking_router_interface_v2.private_network_router_interface) == 0 &&
      length(random_integer.ip_part) == 0
    )
    error_message = "Existing mode must not manage the shared network, subnet or router."
  }

  assert {
    condition = (
      output.private_network_id == "existing-network-id" &&
      output.private_network_name == "Net_VALTION-BURDAVERLAG" &&
      output.private_network_subnet_id == "existing-subnet-id" &&
      output.private_network_subnet_name == "Subnet_VALTION-BURDAVERLAG" &&
      output.private_network_subnet_cidr == "172.20.40.0/24" &&
      output.private_network_router_name == null
    )
    error_message = "Existing mode must export the selected network and actual subnet values."
  }

  assert {
    condition = alltrue([
      for port in concat(openstack_networking_port_v2.worker_port, openstack_networking_port_v2.controlplane_port) :
      port.network_id == "existing-network-id" && one(port.fixed_ip).subnet_id == "existing-subnet-id"
    ])
    error_message = "Every node port must use the selected network and subnet."
  }

  assert {
    condition = (
      openstack_lb_loadbalancer_v2.loadbalancer.vip_subnet_id == "existing-subnet-id" &&
      alltrue([for member in concat(openstack_lb_member_v2.kube_api, openstack_lb_member_v2.talos_api, openstack_lb_member_v2.keystone_auth_controlplane, openstack_lb_member_v2.keystone_auth_worker) : member.subnet_id == "existing-subnet-id"])
    )
    error_message = "The API load balancer and all enabled members must use the selected subnet."
  }

  assert {
    condition = (
      openstack_networking_secgroup_rule_v2.ingress_kube_api_rule_ipv4.remote_ip_prefix == "172.20.40.0/24" &&
      openstack_networking_secgroup_rule_v2.ingress_talos_api_rule_ipv4[0].remote_ip_prefix == "172.20.40.0/24" &&
      openstack_networking_secgroup_rule_v2.ingress_keystone_auth_ipv4[0].remote_ip_prefix == "172.20.40.0/24" &&
      openstack_networking_floatingip_associate_v2.loadbalancer_ip.floating_ip == "192.0.2.10"
    )
    error_message = "Firewall rules must use the actual subnet CIDR and the API floating IP must be reused."
  }
}

run "managed_network" {
  command = plan

  variables {
    os_private_network_mode        = "managed"
    os_private_network_name        = "private-network"
    os_private_network_subnet_name = ""
    os_private_network_cidr        = "172.23.0.0/24"
  }

  assert {
    condition = (
      length(data.openstack_networking_network_v2.private_network) == 0 &&
      length(data.openstack_networking_subnet_v2.private_network_subnet) == 0 &&
      length(openstack_networking_network_v2.private_network) == 1 &&
      length(openstack_networking_subnet_v2.private_network_subnet) == 1 &&
      length(openstack_networking_router_v2.private_network_router) == 1 &&
      length(openstack_networking_router_interface_v2.private_network_router_interface) == 1 &&
      length(random_integer.ip_part) == 0
    )
    error_message = "Managed mode must create networking rather than look up a private network."
  }

  assert {
    condition = (
      output.private_network_id == "managed-network-id" &&
      output.private_network_name == "test-cluster-private-network" &&
      output.private_network_subnet_name == "test-cluster-private-network-subnet" &&
      output.private_network_subnet_cidr == "172.23.0.0/24" &&
      output.private_network_router_name == "test-cluster-router" &&
      openstack_lb_loadbalancer_v2.loadbalancer.vip_subnet_id == "managed-subnet-id" &&
      openstack_networking_secgroup_rule_v2.ingress_kube_api_rule_ipv4.remote_ip_prefix == "172.23.0.0/24"
    )
    error_message = "Managed mode must preserve legacy names and propagate the configured subnet."
  }
}

run "managed_generated_cidr" {
  command = plan

  variables {
    os_private_network_mode        = "managed"
    os_private_network_subnet_name = ""
  }

  assert {
    condition = (
      length(random_integer.ip_part) == 1 &&
      output.private_network_subnet_cidr == "10.160.0.0/16" &&
      openstack_networking_secgroup_rule_v2.ingress_kube_api_rule_ipv4.remote_ip_prefix == "10.160.0.0/16"
    )
    error_message = "Managed mode must generate and propagate a CIDR when no override is supplied."
  }
}

run "managed_subnet_name_override" {
  command = plan

  variables {
    os_private_network_mode        = "managed"
    os_private_network_subnet_name = "custom-subnet"
    os_private_network_cidr        = "172.23.0.0/24"
  }

  assert {
    condition     = output.private_network_subnet_name == "custom-subnet"
    error_message = "Managed mode must respect an explicit subnet name."
  }
}

run "invalid_mode" {
  command = plan

  variables {
    os_private_network_mode = "invalid"
  }

  expect_failures = [var.os_private_network_mode]
}

run "missing_existing_subnet_name" {
  command = plan

  variables {
    os_private_network_subnet_name = " "
  }

  expect_failures = [data.openstack_networking_network_v2.public_network]
}

run "existing_cidr_override" {
  command = plan

  variables {
    os_private_network_cidr = "172.23.0.0/24"
  }

  expect_failures = [data.openstack_networking_network_v2.public_network]
}

run "subnet_lookup_scope" {
  command = plan

  assert {
    condition = (
      data.openstack_networking_subnet_v2.private_network_subnet[0].network_id == output.private_network_id &&
      data.openstack_networking_subnet_v2.private_network_subnet[0].ip_version == 4
    )
    error_message = "The subnet lookup must be scoped to the selected network and IPv4."
  }
}

run "ipv6_subnet" {
  command = plan

  override_data {
    target = data.openstack_networking_subnet_v2.private_network_subnet[0]
    values = {
      id   = "existing-subnet-id"
      cidr = "fd00::/64"
    }
  }

  expect_failures = [data.openstack_networking_subnet_v2.private_network_subnet]
}

run "invalid_managed_cidr" {
  command = plan

  variables {
    os_private_network_mode = "managed"
    os_private_network_cidr = "invalid"
  }

  expect_failures = [var.os_private_network_cidr]
}