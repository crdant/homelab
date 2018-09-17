variable "vsphere_user" {
  type = "string"
}

variable "vsphere_password" {
  type = "string"
}

variable "vsphere_host" {
  type = "string"
}

locals {
  vsphere_fqdn = "${var.vsphere_host}.${var.domain}"
}

data "vsphere_host" "homelab" {
  name = "${local.vsphere_fqdn}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"

  depends_on = [ "vsphere_compute_cluster.homelab" ]
}

output "vsphere_host" {
  value = "${data.vsphere_host.homelab.name}"
}
