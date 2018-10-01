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
  # operations manager
  opsman_ip = "${cidrhost(local.infrastructure_cidr,10)}"
  director_ip = "${cidrhost(local.infrastructure_cidr,11)}"

  # pas load balanaced
  pas_wildcard_ip = "${cidrhost(local.balancer_external_cidr,10)}"
  tcp_router_ip = "${cidrhost(local.balancer_external_cidr,20)}"
  pas_ssh_ip = "${cidrhost(local.balancer_external_cidr,30)}"

  # pas statics
  gorouter_ips = [
      "${cidrhost(local.deployment_cidr, -15)}",
    ]
  brain_ips = [
      "${cidrhost(local.deployment_cidr, -10)}",
    ]
  tcp_router_ips = [
      "${cidrhost(local.deployment_cidr, -5)}",
    ]
  pas_mysql_ips = [
      "${cidrhost(local.deployment_cidr, -20)}",
    ]

  pks_wildcard_ip = "${cidrhost(local.balancer_external_cidr, 20)}"
}

output "vcenter_server_ip" {
  value = "${local.vcenter_server_ip}"
}

output "gorouter_ips" {
  value = "${local.gorouter_ips}"
}

output "brain_ips" {
  value = "${local.brain_ips}"
}

output "tcp_router_ips" {
  value = "${local.tcp_router_ips}"
}

output "pas_mysql_ips" {
  value = "${local.pas_mysql_ips}"
}

output "pks_wildcard_ip" {
  value = "${local.pks_wildcard_ip}"
}
