provider "vsphere" {
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"
  vsphere_server = "${local.vsphere_ip}"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}
