moved {
  from = openstack_networking_network_v2.private_network
  to   = openstack_networking_network_v2.private_network[0]
}

moved {
  from = openstack_networking_subnet_v2.private_network_subnet
  to   = openstack_networking_subnet_v2.private_network_subnet[0]
}

moved {
  from = openstack_networking_router_v2.private_network_router
  to   = openstack_networking_router_v2.private_network_router[0]
}

moved {
  from = openstack_networking_router_interface_v2.private_network_router_interface
  to   = openstack_networking_router_interface_v2.private_network_router_interface[0]
}

resource "random_integer" "ip_part" {
  count = var.os_private_network_mode == "managed" && var.os_private_network_cidr == "" ? 1 : 0

  min = 112
  max = 243
}

locals {
  create_private_network      = var.os_private_network_mode == "managed"
  managed_network_cidr        = var.os_private_network_cidr != "" ? var.os_private_network_cidr : (local.create_private_network ? "10.${random_integer.ip_part[0].result}.0.0/16" : "")
  private_network_id          = local.create_private_network ? openstack_networking_network_v2.private_network[0].id : data.openstack_networking_network_v2.private_network[0].id
  private_network_name        = local.create_private_network ? openstack_networking_network_v2.private_network[0].name : data.openstack_networking_network_v2.private_network[0].name
  private_network_subnet_id   = local.create_private_network ? openstack_networking_subnet_v2.private_network_subnet[0].id : data.openstack_networking_subnet_v2.private_network_subnet[0].id
  private_network_subnet_name = local.create_private_network ? openstack_networking_subnet_v2.private_network_subnet[0].name : data.openstack_networking_subnet_v2.private_network_subnet[0].name
  private_network_subnet_cidr = local.create_private_network ? openstack_networking_subnet_v2.private_network_subnet[0].cidr : data.openstack_networking_subnet_v2.private_network_subnet[0].cidr
}

data "openstack_networking_network_v2" "public_network" {
  name = var.os_public_network_name

  lifecycle {
    precondition {
      condition     = local.create_private_network || trimspace(var.os_private_network_subnet_name) != ""
      error_message = "Existing networking requires an explicit private subnet name."
    }

    precondition {
      condition     = local.create_private_network || var.os_private_network_cidr == ""
      error_message = "Existing networking derives its CIDR from the subnet; leave os_private_network_cidr empty."
    }

  }
}

data "openstack_networking_network_v2" "private_network" {
  count = local.create_private_network ? 0 : 1

  name = var.os_private_network_name
}

data "openstack_networking_subnet_v2" "private_network_subnet" {
  count = local.create_private_network ? 0 : 1

  name       = var.os_private_network_subnet_name
  network_id = data.openstack_networking_network_v2.private_network[0].id
  ip_version = 4

  lifecycle {
    postcondition {
      condition     = self.network_id == data.openstack_networking_network_v2.private_network[0].id
      error_message = "The selected private subnet must belong to the selected private network."
    }

    postcondition {
      condition     = self.ip_version == 4 && can(cidrnetmask(self.cidr))
      error_message = "The selected private subnet must use IPv4."
    }
  }
}

resource "openstack_networking_network_v2" "private_network" {
  count = local.create_private_network ? 1 : 0

  name = "${var.name_prefix}-${var.os_private_network_name}"
}

resource "openstack_networking_subnet_v2" "private_network_subnet" {
  count = local.create_private_network ? 1 : 0

  name       = var.os_private_network_subnet_name != "" ? var.os_private_network_subnet_name : "${var.name_prefix}-${var.os_private_network_name}-subnet"
  cidr       = local.managed_network_cidr
  ip_version = 4
  network_id = openstack_networking_network_v2.private_network[0].id
}

resource "openstack_networking_router_v2" "private_network_router" {
  count = local.create_private_network ? 1 : 0

  name                = "${var.name_prefix}-router"
  external_network_id = data.openstack_networking_network_v2.public_network.id
}

resource "openstack_networking_router_interface_v2" "private_network_router_interface" {
  count = local.create_private_network ? 1 : 0

  router_id = openstack_networking_router_v2.private_network_router[0].id
  subnet_id = openstack_networking_subnet_v2.private_network_subnet[0].id
}

resource "openstack_networking_secgroup_v2" "private_network_allow_internal" {
  name = "${var.name_prefix}-${var.os_private_network_name}-allow-internal"
}

resource "openstack_networking_secgroup_rule_v2" "private_network_allow_internal_ipv4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_group_id   = openstack_networking_secgroup_v2.private_network_allow_internal.id
  security_group_id = openstack_networking_secgroup_v2.private_network_allow_internal.id
}

resource "openstack_networking_secgroup_v2" "external" {
  name = "${var.name_prefix}-external"
}

resource "openstack_networking_secgroup_rule_v2" "ingress_kube_api_rule_ipv4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  security_group_id = openstack_networking_secgroup_v2.external.id
  remote_ip_prefix  = local.private_network_subnet_cidr
}

resource "openstack_networking_secgroup_rule_v2" "ingress_talos_api_rule_ipv4" {
  count = var.enable_talos_api ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 50000
  port_range_max    = 50000
  security_group_id = openstack_networking_secgroup_v2.external.id
  remote_ip_prefix  = local.private_network_subnet_cidr
}

resource "openstack_networking_secgroup_rule_v2" "ingress_k0s_api_rule_ipv4" {
  count = var.enable_k0s_api ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 9443
  port_range_max    = 9443
  security_group_id = openstack_networking_secgroup_v2.external.id
  remote_ip_prefix  = local.private_network_subnet_cidr
}

resource "openstack_networking_secgroup_rule_v2" "ingress_konnectivity_rule_ipv4" {
  count = var.enable_konnectivity ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8132
  port_range_max    = 8132
  security_group_id = openstack_networking_secgroup_v2.external.id
  remote_ip_prefix  = local.private_network_subnet_cidr
}

resource "openstack_networking_secgroup_rule_v2" "ingress_ssh_ipv4" {
  count = var.enable_ssh_bastion ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  security_group_id = openstack_networking_secgroup_v2.external.id
  remote_ip_prefix  = local.private_network_subnet_cidr
}

resource "openstack_networking_secgroup_rule_v2" "ingress_keystone_auth_ipv4" {
  count = var.enable_keystone_auth ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.keystone_auth_port
  port_range_max    = var.keystone_auth_port
  security_group_id = openstack_networking_secgroup_v2.external.id
  remote_ip_prefix  = local.private_network_subnet_cidr
}

resource "openstack_networking_port_v2" "bastion_port" {
  count = var.enable_ssh_bastion ? 1 : 0

  name       = "${var.name_prefix}-bastion"
  network_id = local.private_network_id
  security_group_ids = [
    openstack_networking_secgroup_v2.external.id,
    openstack_networking_secgroup_v2.private_network_allow_internal.id
  ]

  fixed_ip {
    subnet_id = local.private_network_subnet_id
  }
}

resource "openstack_networking_port_v2" "worker_port" {
  count      = var.worker_count
  name       = "${var.name_prefix}-worker-${count.index}"
  network_id = local.private_network_id
  security_group_ids = concat(
    var.enable_ssh_bastion ? [openstack_networking_secgroup_v2.external.id] : [],
    [openstack_networking_secgroup_v2.private_network_allow_internal.id]
  )

  fixed_ip {
    subnet_id = local.private_network_subnet_id
  }
}

resource "openstack_networking_port_v2" "controlplane_port" {
  count      = var.controlplane_count
  name       = "${var.name_prefix}-controlplane-${count.index}"
  network_id = local.private_network_id
  security_group_ids = [
    openstack_networking_secgroup_v2.external.id,
    openstack_networking_secgroup_v2.private_network_allow_internal.id
  ]

  fixed_ip {
    subnet_id = local.private_network_subnet_id
  }
}

resource "openstack_lb_loadbalancer_v2" "loadbalancer" {
  name          = "${var.name_prefix}-loadbalancer"
  vip_subnet_id = local.private_network_subnet_id
}

resource "openstack_lb_listener_v2" "kube_api" {
  name            = "${var.name_prefix}-kube-api"
  loadbalancer_id = openstack_lb_loadbalancer_v2.loadbalancer.id
  protocol        = "TCP"
  protocol_port   = var.kube_api_external_port
}

resource "openstack_lb_pool_v2" "kube_api" {
  name        = "${var.name_prefix}-kube-api"
  lb_method   = "ROUND_ROBIN"
  listener_id = openstack_lb_listener_v2.kube_api.id
  protocol    = "TCP"
}

resource "openstack_lb_monitor_v2" "kube_api" {
  pool_id     = openstack_lb_pool_v2.kube_api.id
  delay       = 10
  max_retries = 3
  timeout     = 3
  type        = "TLS-HELLO"
}

resource "openstack_lb_member_v2" "kube_api" {
  count = var.controlplane_count

  name          = "${var.name_prefix}-kube-api-${count.index}"
  address       = openstack_networking_port_v2.controlplane_port[count.index].all_fixed_ips[0]
  pool_id       = openstack_lb_pool_v2.kube_api.id
  protocol_port = 6443
  subnet_id     = local.private_network_subnet_id
}

resource "openstack_lb_listener_v2" "talos_api" {
  count = var.enable_talos_api ? 1 : 0

  name            = "${var.name_prefix}-talos-api"
  loadbalancer_id = openstack_lb_loadbalancer_v2.loadbalancer.id
  protocol        = "TCP"
  protocol_port   = 50000
}

resource "openstack_lb_pool_v2" "talos_api" {
  count = var.enable_talos_api ? 1 : 0

  name        = "${var.name_prefix}-talos-api"
  lb_method   = "ROUND_ROBIN"
  listener_id = openstack_lb_listener_v2.talos_api[count.index].id
  protocol    = "TCP"
}

resource "openstack_lb_monitor_v2" "talos_api" {
  count = var.enable_talos_api ? 1 : 0

  pool_id     = openstack_lb_pool_v2.talos_api[count.index].id
  delay       = 10
  max_retries = 3
  timeout     = 3
  type        = "TLS-HELLO"
}

resource "openstack_lb_member_v2" "talos_api" {
  count = var.enable_talos_api ? var.controlplane_count : 0

  name          = "${var.name_prefix}-talos-api-${count.index}"
  address       = openstack_networking_port_v2.controlplane_port[count.index].all_fixed_ips[0]
  pool_id       = openstack_lb_pool_v2.talos_api[0].id
  protocol_port = 50000
  subnet_id     = local.private_network_subnet_id
}

resource "openstack_lb_listener_v2" "k0s_api" {
  count = var.enable_k0s_api ? 1 : 0

  name            = "${var.name_prefix}-k0s-api"
  loadbalancer_id = openstack_lb_loadbalancer_v2.loadbalancer.id
  protocol        = "TCP"
  protocol_port   = 9443
}

resource "openstack_lb_pool_v2" "k0s_api" {
  count = var.enable_k0s_api ? 1 : 0

  name        = "${var.name_prefix}-k0s-api"
  lb_method   = "ROUND_ROBIN"
  listener_id = openstack_lb_listener_v2.k0s_api[count.index].id
  protocol    = "TCP"
}

resource "openstack_lb_monitor_v2" "k0s_api" {
  count = var.enable_k0s_api ? 1 : 0

  pool_id     = openstack_lb_pool_v2.k0s_api[count.index].id
  delay       = 10
  max_retries = 3
  timeout     = 3
  type        = "TCP"
}

resource "openstack_lb_member_v2" "k0s_api" {
  count = var.enable_k0s_api ? var.controlplane_count : 0

  name          = "${var.name_prefix}-k0s-api-${count.index}"
  address       = openstack_networking_port_v2.controlplane_port[count.index].all_fixed_ips[0]
  pool_id       = openstack_lb_pool_v2.k0s_api[0].id
  protocol_port = 9443
  subnet_id     = local.private_network_subnet_id
}

resource "openstack_lb_listener_v2" "konnectivity" {
  count = var.enable_konnectivity ? 1 : 0

  name            = "${var.name_prefix}-konnectivity"
  loadbalancer_id = openstack_lb_loadbalancer_v2.loadbalancer.id
  protocol        = "TCP"
  protocol_port   = 8132
}

resource "openstack_lb_pool_v2" "konnectivity" {
  count = var.enable_konnectivity ? 1 : 0

  name        = "${var.name_prefix}-konnectivity"
  lb_method   = "ROUND_ROBIN"
  listener_id = openstack_lb_listener_v2.konnectivity[count.index].id
  protocol    = "TCP"
}

resource "openstack_lb_monitor_v2" "konnectivity" {
  count = var.enable_konnectivity ? 1 : 0

  pool_id     = openstack_lb_pool_v2.konnectivity[count.index].id
  delay       = 5
  max_retries = 4
  timeout     = 10
  type        = "TCP"
}

resource "openstack_lb_member_v2" "konnectivity" {
  count = var.enable_konnectivity ? var.controlplane_count : 0

  name          = "${var.name_prefix}-konnectivity-${count.index}"
  address       = openstack_networking_port_v2.controlplane_port[count.index].all_fixed_ips[0]
  pool_id       = openstack_lb_pool_v2.konnectivity[0].id
  protocol_port = 8132
  subnet_id     = local.private_network_subnet_id
}

resource "openstack_lb_listener_v2" "ssh_bastion" {
  count = var.enable_ssh_bastion ? 1 : 0

  name            = "${var.name_prefix}-ssh-bastion"
  loadbalancer_id = openstack_lb_loadbalancer_v2.loadbalancer.id
  protocol        = "TCP"
  protocol_port   = 22
}

resource "openstack_lb_pool_v2" "ssh_bastion" {
  count = var.enable_ssh_bastion ? 1 : 0

  name        = "${var.name_prefix}-ssh-bastion"
  lb_method   = "ROUND_ROBIN"
  listener_id = openstack_lb_listener_v2.ssh_bastion[count.index].id
  protocol    = "TCP"
}

resource "openstack_lb_monitor_v2" "ssh_bastion" {
  count = var.enable_ssh_bastion ? 1 : 0

  pool_id     = openstack_lb_pool_v2.ssh_bastion[count.index].id
  delay       = 10
  max_retries = 3
  timeout     = 3
  type        = "TCP"
}

resource "openstack_lb_member_v2" "ssh_bastion" {
  count = var.enable_ssh_bastion ? 1 : 0

  name          = "${var.name_prefix}-ssh-bastion"
  address       = openstack_networking_port_v2.bastion_port[count.index].all_fixed_ips[0]
  pool_id       = openstack_lb_pool_v2.ssh_bastion[count.index].id
  protocol_port = 22
  subnet_id     = local.private_network_subnet_id
}

resource "openstack_lb_listener_v2" "keystone_auth" {
  count = var.enable_keystone_auth ? 1 : 0

  name            = "${var.name_prefix}-keystone-auth"
  loadbalancer_id = openstack_lb_loadbalancer_v2.loadbalancer.id
  protocol        = "TCP"
  protocol_port   = var.keystone_auth_port
}

resource "openstack_lb_pool_v2" "keystone_auth" {
  count = var.enable_keystone_auth ? 1 : 0

  name        = "${var.name_prefix}-keystone-auth"
  lb_method   = "ROUND_ROBIN"
  listener_id = openstack_lb_listener_v2.keystone_auth[count.index].id
  protocol    = "TCP"
}

resource "openstack_lb_monitor_v2" "keystone_auth" {
  count = var.enable_keystone_auth ? 1 : 0

  pool_id     = openstack_lb_pool_v2.keystone_auth[count.index].id
  delay       = 10
  max_retries = 3
  timeout     = 3
  type        = "TCP"
}

resource "openstack_lb_member_v2" "keystone_auth_controlplane" {
  count = (var.enable_talos_api && var.enable_keystone_auth) ? var.controlplane_count : 0

  name          = "${var.name_prefix}-keystone-auth"
  address       = openstack_networking_port_v2.controlplane_port[count.index].all_fixed_ips[0]
  pool_id       = openstack_lb_pool_v2.keystone_auth[0].id
  protocol_port = var.keystone_auth_port
  subnet_id     = local.private_network_subnet_id
}

resource "openstack_lb_member_v2" "keystone_auth_worker" {
  count = var.enable_keystone_auth ? var.worker_count : 0

  name          = "${var.name_prefix}-keystone-auth"
  address       = openstack_networking_port_v2.worker_port[count.index].all_fixed_ips[0]
  pool_id       = openstack_lb_pool_v2.keystone_auth[0].id
  protocol_port = var.keystone_auth_port
  subnet_id     = local.private_network_subnet_id
}

resource "openstack_networking_floatingip_associate_v2" "loadbalancer_ip" {
  floating_ip = var.kube_api_external_ip
  port_id     = openstack_lb_loadbalancer_v2.loadbalancer.vip_port_id
}
