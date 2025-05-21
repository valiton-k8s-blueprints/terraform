data "openstack_images_image_v2" "talos" {
  name = var.image_name
}

data "openstack_compute_flavor_v2" "worker_flavor" {
  name = var.worker_instance_flavor
}

data "openstack_compute_flavor_v2" "controlplane_flavor" {
  name = var.controlplane_instance_flavor
}

resource "openstack_compute_instance_v2" "worker" {
  count = var.worker_count

  name      = "${var.name_prefix}-worker-${count.index}"
  flavor_id = data.openstack_compute_flavor_v2.worker_flavor.id
  user_data = var.worker_user_data

  block_device {
    uuid                  = data.openstack_images_image_v2.talos.id
    source_type           = "image"
    volume_size           = var.worker_volume_size
    boot_index            = 0
    destination_type      = "volume"
    volume_type           = var.worker_volume_type
    delete_on_termination = true
  }

  network {
    port = var.worker_port_id[count.index]
  }

  lifecycle {
    ignore_changes = [user_data]
  }
}

resource "openstack_compute_instance_v2" "controlplane" {
  count = var.controlplane_count

  name      = "${var.name_prefix}-controlplane-${count.index}"
  flavor_id = data.openstack_compute_flavor_v2.controlplane_flavor.id

  block_device {
    uuid                  = data.openstack_images_image_v2.talos.id
    source_type           = "image"
    volume_size           = var.controlplane_volume_size
    boot_index            = 0
    destination_type      = "volume"
    volume_type           = var.controlplane_volume_type
    delete_on_termination = true
  }

  network {
    port = var.controlplane_port_id[count.index]
  }
}
