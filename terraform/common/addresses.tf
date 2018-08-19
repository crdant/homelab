# router

locals {
  router_alias = "router.${var.domain}"
  vsphere_alias = "esxi.${var.domain}"
  vcenter_alias = "vcenter.${var.domain}"
  outside_alias = "pigeon.${var.domain}"
}

# vsphere
locals {
  vsphere_fqdn = "${var.vsphere_host}.${var.domain}"
  vsphere_ip = "${cidrhost(local.vmware_cidr, 10)}"
}

# vcenter
locals {
  vcenter_fqdn = "${var.vcenter_host}.${var.domain}"
  vcenter_ip = "${cidrhost(local.vmware_cidr, 20)}"
}

# pcf
locals {
  gorouter_ips = [
      "${cidrhost(local.deployment_cidr, -15)}",
      "${cidrhost(local.deployment_cidr, -14)}",
      "${cidrhost(local.deployment_cidr, -13)}"
    ]
  brain_ips = [
      "${cidrhost(local.deployment_cidr, -10)}",
      "${cidrhost(local.deployment_cidr, -9)}",
      "${cidrhost(local.deployment_cidr, -8)}"
    ]
  tcp_router_ips = [
      "${cidrhost(local.deployment_cidr, -5)}",
      "${cidrhost(local.deployment_cidr, -4)}",
      "${cidrhost(local.deployment_cidr, -3)}"
    ]
}
