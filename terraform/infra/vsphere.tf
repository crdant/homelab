variable "host" {
  type = "string"
}

variable "vcenter_host" {
  type = "string"
}

locals {
  host_fqdn = "${var.host}.${var.domain}"
  host_ip = "${cidrhost(var.vmware_cidr, 1)}"
  vcenter_fqdn = "${var.vcenter_host}.${var.domain}"
  vcenter_ip = "${cidrhost(var.vmware_cidr,2)}"
}
