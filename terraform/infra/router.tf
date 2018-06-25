variable "router_host" {
  type = "string"
}

variable "admin_user" {
  type = "string"
}

variable "vpn_users" {
  type = "list"
}

locals {
  router_fqdn = "${var.router_host}.${var.domain}"
  router_ip = "${cidrhost(var.local_cidr, 1)}"
}

locals {
  vpn_start_address  = "${cidrhost(var.vpn_cidr, 10)}"
  vpn_end_address  = "${cidrhost(var.vpn_cidr, 50)}"
}

locals {
  gorouter_addresses = [
      "${cidrhost(var.deployment_cidr, -15)}",
      "${cidrhost(var.deployment_cidr, -14)}",
      "${cidrhost(var.deployment_cidr, -13)}"
    ]
  brain_addresses = [
      "${cidrhost(var.deployment_cidr, -10)}",
      "${cidrhost(var.deployment_cidr, -9)}",
      "${cidrhost(var.deployment_cidr, -8)}"
    ]
  tcp_router_addresses = [
      "${cidrhost(var.deployment_cidr, -5)}",
      "${cidrhost(var.deployment_cidr, -4)}",
      "${cidrhost(var.deployment_cidr, -3)}"
    ]
}

variable bosh_ports {
  type = "list"
  default = [ "22", "443", "6868", "8443", "8844", "25555" ]
}

variable tcp_router_ports {
  type = "list"
  default = [ "1024-65535", 80 ]
}

resource "random_pet" "admin_password" {
  length = 4
}

resource "random_pet" "vpn_psk" {
  length = 4
}

resource "random_pet" "vpn_password" {
  count = "${length(var.vpn_users)}"
  length = 4
}

resource "tls_private_key" "router_admin" {
  algorithm   = "RSA"
  rsa_bits    = 4096
}

resource "local_file" "router_admin_private_key" {
  content  = "${tls_private_key.router_admin.private_key_pem}"
  filename = "${var.key_dir}/id_router_admin.pem"
}

data "template_file" "vpn_users" {
  template = "${file("${var.template_dir}/router/components/vpn-user-entry.tpl")}"
  count    = "${length(var.vpn_users)}"
  vars {
    user = "${var.vpn_users[count.index]}"
    password = "${element(random_pet.vpn_password.*.id, count.index)}"
  }
}

data "template_file" "bosh_port_group" {
  template = "${file("${var.template_dir}/router/components/address-group-entry.tpl")}"
  count    = "${length(var.bosh_ports)}"
  vars {
    address = "${var.bosh_ports[count.index]}"
  }
}

data "template_file" "gorouter_address_group" {
  template = "${file("${var.template_dir}/router/components/address-group-entry.tpl")}"
  count    = "${length(local.gorouter_addresses)}"
  vars {
    address = "${local.gorouter_addresses[count.index]}"
  }
}

data "template_file" "brain_address_group" {
  template = "${file("${var.template_dir}/router/components/address-group-entry.tpl")}"
  count    = "${length(local.brain_addresses)}"
  vars {
    address = "${local.brain_addresses[count.index]}"
  }
}

data "template_file" "tcp_router_address_group" {
  template = "${file("${var.template_dir}/router/components/address-group-entry.tpl")}"
  count    = "${length(local.tcp_router_addresses)}"
  vars {
    address = "${local.tcp_router_addresses[count.index]}"
  }
}

data "template_file" "tcp_router_port_group" {
  template = "${file("${var.template_dir}/router/components/address-group-entry.tpl")}"
  count    = "${length(var.tcp_router_ports)}"
  vars {
    address = "${var.tcp_router_ports[count.index]}"
  }
}

data "template_file" "router_config" {
  template        = "${file("${var.template_dir}/router/config.boot")}"
  vars {
    /* admin */
    admin_user = "${var.admin_user}"
    admin_password = "${random_pet.admin_password.id}"
    admin_key_type = "${lower(tls_private_key.router_admin.algorithm)}"
    admin_public_key = "${tls_private_key.router_admin.public_key_openssh}"

    /* router */
    router_ip = "${local.router_ip}"
    router_fqdn = "${local.router_fqdn}"
    local_cidr = "${var.local_cidr}"
    local_dhcp_start_addr = "${cidrhost(var.local_cidr, 10)}"
    local_dhcp_end_addr = "${cidrhost(var.local_cidr, 50)}"

    /* dns - can't use a list in a template */
    primary_dns_server  = "${var.dns_servers[0]}"
    secondary_dns_server = "${var.dns_servers[1]}"

    /* infrastructure networks */
    management_cidr = "${var.management_cidr}"
    management_port_ip = "${cidrhost(var.management_cidr,1)}"
    management_dhcp_start_addr = "${cidrhost(var.local_cidr, 10)}"
    management_dhcp_end_addr = "${cidrhost(var.local_cidr, 50)}"
    vmware_cidr = "${var.vmware_cidr}"
    vmware_port_ip = "${cidrhost(var.vmware_cidr,1)}"
    vsphere_ip = "${local.vsphere_ip}"
    bootstrap_cidr = "${var.bootstrap_cidr}"
    bootstrap_port_ip = "${cidrhost(var.bootstrap_cidr,1)}"

    /* load balancer network */
    balancer_external_cidr = "${var.balancer_external_cidr}"
    balancer_external_port_ip = "${cidrhost(var.balancer_external_cidr,1)}"
    balancer_internal_cidr = "${var.balancer_internal_cidr}"
    balancer_internal_port_ip = "${cidrhost(var.balancer_internal_cidr,1)}"

    /* PCF network addresses */
    pcf_port_ip = "${cidrhost(var.pcf_cidr,1)}"
    infrastructure_cidr = "${var.infrastructure_cidr}"
    infrastructure_port_ip = "${cidrhost(var.infrastructure_cidr,1)}"
    deployment_cidr = "${var.deployment_cidr}"
    deployment_port_ip = "${cidrhost(var.deployment_cidr,1)}"
    services_cidr = "${var.services_cidr}"
    services_port_ip = "${cidrhost(var.services_cidr,1)}"
    dynamic_cidr = "${var.dynamic_cidr}"
    dynamic_port_ip = "${cidrhost(var.dynamic_cidr,1)}"
    container_cidr = "${var.container_cidr}"
    container_port_ip = "${cidrhost(var.container_cidr,1)}"

    /* vpn */
    vpn_cidr = "${var.vpn_cidr}"
    vpn_psk = "${random_pet.vpn_psk.id}"
    vpn_users = "${join("          ", data.template_file.vpn_users.*.rendered)}"
    vpn_password = "${random_pet.vpn_password.id}"
    vpn_start_address = "${local.vpn_start_address}"
    vpn_end_address = "${local.vpn_end_address}"

    /* firewall */
    bosh_port_group = "${join("          ", data.template_file.bosh_port_group.*.rendered)}"
    gorouter_address_group = "${join("          ", data.template_file.gorouter_address_group.*.rendered)}"
    brain_address_group = "${join("          ", data.template_file.brain_address_group.*.rendered)}"
    tcp_router_address_group = "${join("          ", data.template_file.tcp_router_address_group.*.rendered)}"
    tcp_router_port_group = "${join("          ", data.template_file.tcp_router_port_group.*.rendered)}"
  }

}

resource "local_file" "router_config" {
  content  = "${data.template_file.router_config.rendered}"
  filename = "${var.work_dir}/router/config.boot"
}
