data "openstack_images_image_v2" "bastion" {
  name = var.image_name
}

data "openstack_compute_flavor_v2" "flavor" {
  name = var.instance_flavor
}

resource "openstack_compute_instance_v2" "bastion" {
  name      = "${var.name_prefix}-bastion"
  flavor_id = data.openstack_compute_flavor_v2.flavor.id
  key_pair  = var.keypair_name

  block_device {
    uuid                  = data.openstack_images_image_v2.bastion.id
    source_type           = "image"
    volume_size           = var.volume_size
    boot_index            = 0
    destination_type      = "volume"
    volume_type           = var.volume_type
    delete_on_termination = true
  }

  network {
    port = var.port_id
  }
}
