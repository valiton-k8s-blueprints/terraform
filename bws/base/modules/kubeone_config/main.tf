data "ct_config" "controlplane_ignition" {
  content = templatefile(
    "${path.module}/butane/butane_yaml.tftpl",
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
  strict = true
}
