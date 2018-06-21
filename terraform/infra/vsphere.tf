variable "vsphere_host" {
  type = "string"
}

variable "vcenter_host" {
  type = "string"
}

locals {
  vsphere_fqdn = "${var.vsphere_host}.${var.domain}"
  vsphere_ip = "${cidrhost(var.vmware_cidr, 10)}"
  vcenter_fqdn = "${var.vcenter_host}.${var.domain}"
  vcenter_ip = "${cidrhost(var.vmware_cidr, 20)}"
}
