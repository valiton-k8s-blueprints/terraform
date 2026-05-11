locals {
  content_butane = templatefile(
    "${path.module}/templates/butane_yaml.tftpl",
    {
      files = [
        {
          path    = "/etc/kubernetes/pki/ca.crt"
          content = "data:text/plain;base64,${base64encode(var.ca_crt)}"
        },
        {
          path    = "/etc/kubernetes/pki/ca.key"
          content = "data:text/plain;base64,${base64encode(var.ca_key)}"
        }
      ]
    }
  )
  content_cloud_init = templatefile(
    "${path.module}/templates/cloud-init.tftpl",
    {
      files = [
        {
          path    = "/etc/kubernetes/pki/ca.crt"
          content = var.ca_crt
        },
        {
          path    = "/etc/kubernetes/pki/ca.key"
          content = var.ca_key
        }
      ]
    }
  )
  content_ignition = data.ct_config.controlplane_ignition.rendered
}

data "ct_config" "controlplane_ignition" {
  content = local.content_butane
  strict = true
}
