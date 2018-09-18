provider "vsphere" {
  vsphere_server = "${var.vcenter_ip}"
  user           = "${var.vcenter_user}"
  password       = "${var.vcenter_password}"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}
