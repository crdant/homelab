provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

provider "vsphere" {
  alias = "esxi"
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"
  vsphere_server = "${local.vsphere_fqdn}"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

provider vsphere {
  alias          = "vcenter"
  user           = "${local.vcenter_user}"
  password       = "${random_string.vcenter_password.result}"
  vsphere_server = "${local.vcenter_fqdn}"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}
