data "openstack_networking_network_v2" "public_network" {
  name = var.os_public_network_name
}

resource "openstack_networking_network_v2" "private_network" {
  name = "${var.name_prefix}-${var.os_private_network_name}"
}

resource "openstack_networking_subnet_v2" "private_network_subnet" {
  name       = "${var.name_prefix}-${var.os_private_network_name}-subnet"
  cidr       = var.os_private_network_cidr
  ip_version = 4
  network_id = openstack_networking_network_v2.private_network.id
}

resource "openstack_networking_router_v2" "private_network_router" {
  name                = "${var.name_prefix}-router"
  external_network_id = data.openstack_networking_network_v2.public_network.id
}

resource "openstack_networking_router_interface_v2" "private_network_router_interface" {
  router_id = openstack_networking_router_v2.private_network_router.id
  subnet_id = openstack_networking_subnet_v2.private_network_subnet.id
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
  remote_ip_prefix  = var.os_private_network_cidr
}

resource "openstack_networking_secgroup_rule_v2" "ingress_talos_api_rule_ipv4" {
  count = var.enable_talos_api ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 50000
  port_range_max    = 50000
  security_group_id = openstack_networking_secgroup_v2.external.id
  remote_ip_prefix  = var.os_private_network_cidr
}

resource "openstack_networking_secgroup_rule_v2" "ingress_ssh_ipv4" {
  count = var.enable_ssh_bastion ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  security_group_id = openstack_networking_secgroup_v2.external.id
  remote_ip_prefix  = var.os_private_network_cidr
}

resource "openstack_networking_port_v2" "bastion_port" {
  count = var.enable_ssh_bastion ? 1 : 0

  name       = "${var.name_prefix}-bastion"
  network_id = openstack_networking_network_v2.private_network.id
  security_group_ids = [
    openstack_networking_secgroup_v2.external.id,
    openstack_networking_secgroup_v2.private_network_allow_internal.id
  ]

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.private_network_subnet.id
  }
}

resource "openstack_networking_port_v2" "worker_port" {
  count      = var.worker_count
  name       = "${var.name_prefix}-worker-${count.index}"
  network_id = openstack_networking_network_v2.private_network.id
  security_group_ids = concat(
    var.enable_ssh_bastion ? [openstack_networking_secgroup_v2.external.id] : [],
    [openstack_networking_secgroup_v2.private_network_allow_internal.id]
  )

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.private_network_subnet.id
  }
}

resource "openstack_networking_port_v2" "controlplane_port" {
  count      = var.controlplane_count
  name       = "${var.name_prefix}-controlplane-${count.index}"
  network_id = openstack_networking_network_v2.private_network.id
  security_group_ids = [
    openstack_networking_secgroup_v2.external.id,
    openstack_networking_secgroup_v2.private_network_allow_internal.id
  ]

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.private_network_subnet.id
  }
}

resource "openstack_lb_loadbalancer_v2" "talos_k8s_endpoint" {
  name          = "${var.name_prefix}-talos-k8s-endpoint"
  vip_subnet_id = openstack_networking_subnet_v2.private_network_subnet.id
}

resource "openstack_lb_listener_v2" "kube_api" {
  name            = "${var.name_prefix}-kube-api"
  loadbalancer_id = openstack_lb_loadbalancer_v2.talos_k8s_endpoint.id
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
  delay       = 5
  max_retries = 4
  timeout     = 10
  type        = "TCP"
}

resource "openstack_lb_member_v2" "kube_api" {
  count = var.controlplane_count

  name          = "${var.name_prefix}-kube-api-${count.index}"
  address       = openstack_networking_port_v2.controlplane_port[count.index].all_fixed_ips[0]
  pool_id       = openstack_lb_pool_v2.kube_api.id
  protocol_port = 6443
  subnet_id     = openstack_networking_subnet_v2.private_network_subnet.id
}

resource "openstack_lb_listener_v2" "talos_api" {
  count = var.enable_talos_api ? 1 : 0

  name            = "${var.name_prefix}-talos-api"
  loadbalancer_id = openstack_lb_loadbalancer_v2.talos_k8s_endpoint.id
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
  delay       = 5
  max_retries = 4
  timeout     = 10
  type        = "TCP"
}

resource "openstack_lb_member_v2" "talos_api" {
  count = var.enable_talos_api ? var.controlplane_count : 0

  name          = "${var.name_prefix}-talos-api-${count.index}"
  address       = openstack_networking_port_v2.controlplane_port[count.index].all_fixed_ips[0]
  pool_id       = openstack_lb_pool_v2.talos_api[0].id
  protocol_port = 50000
  subnet_id     = openstack_networking_subnet_v2.private_network_subnet.id
}

resource "openstack_lb_listener_v2" "ssh_bastion" {
  count = var.enable_ssh_bastion ? 1 : 0

  name            = "${var.name_prefix}-ssh-bastion"
  loadbalancer_id = openstack_lb_loadbalancer_v2.talos_k8s_endpoint.id
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
  delay       = 5
  max_retries = 4
  timeout     = 10
  type        = "TCP"
}

resource "openstack_lb_member_v2" "ssh_bastion" {
  count = var.enable_ssh_bastion ? 1 : 0

  name          = "${var.name_prefix}-ssh-bastion"
  address       = openstack_networking_port_v2.bastion_port[count.index].all_fixed_ips[0]
  pool_id       = openstack_lb_pool_v2.ssh_bastion[count.index].id
  protocol_port = 22
  subnet_id     = openstack_networking_subnet_v2.private_network_subnet.id
}

resource "openstack_networking_floatingip_associate_v2" "talos_k8s_endpoint_ip" {
  floating_ip = var.kube_api_external_ip
  port_id     = openstack_lb_loadbalancer_v2.talos_k8s_endpoint.vip_port_id
}
