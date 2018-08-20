provider "vsphere" {
  alias = "vcenter"
  user           = "${data.terraform_remote_state.vsphere.vcenter_user}"
  password       = "${data.terraform_remote_state.vsphere.vcenter_password}"
  vsphere_server = "${local.vcenter_fqdn}"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}
