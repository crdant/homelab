variable "vcenter_host" {
  type = "string"
}

locals {
  vcenter_fqdn = "${var.vcenter_host}.${var.domain}"
}

provider "vsphere" {
  user           = "${data.terraform_remote_state.vsphere.vcenter_user}"
  password       = "${data.terraform_remote_state.vsphere.vcenter_password}"
  vsphere_server = "${local.vcenter_fqdn}"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

output "vcenter_fqdn" {
  value = "locals.vcenter_fqdn"
}
