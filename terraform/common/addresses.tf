# router
locals {
  router_ip = "${cidrhost(local.local_cidr, 1)}"
  router_management_ip = "${cidrhost(local.management_cidr, 1)}"
}

# vsphere
locals {
  vsphere_ip = "${cidrhost(local.vmware_cidr, 10)}"
}

# vcenter
locals {
  vcenter_server_ip = "${cidrhost(local.vmware_cidr, 20)}"
}

# bootstrap
locals {
  concourse_ip = "${cidrhost(local.bootstrap_static_cidr,10)}"
}

# pipelines

locals {
  # prometheus
  prometheus_ip = "${cidrhost(local.infrastructure_cidr,-10)}"
}

locals {
  # pas statics
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

output "vcenter_server_ip" {
  value = "local.vcenter_ip"
}
