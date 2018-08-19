provider "vsphere" {
  alias = "esxi"
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"
  vsphere_server = "${local.vsphere_fqdn}"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}
