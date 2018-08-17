variable "router_host" {
  type = "string"
}

variable "outside_host" {
  type = "string"
}

variable "admin_user" {
  type = "string"
}

variable "vpn_users" {
  type = "list"
}

variable bosh_ports {
  type = "list"
  default = [ "22", "443", "6868", "8443", "8844", "25555" ]
}

variable gorouter_ports {
  type = "list"
  default = [ "80", "443", "8080" ]
}

variable tcp_router_ports {
  type = "list"
  default = [ "1024-65535", 80 ]
}

variable vsphere_management_ports {
  type = "list"
  default = [ 22, 80, 443, 902 ]
}

variable vcenter_management_ports {
  type = "list"
  default = [ 22, 80, 443, 636, 902, 903, 8080, 8443, 9443, 10080, 10443 ]
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
  template = "${file("${var.template_dir}/router/components/port-group-entry.tpl")}"
  count    = "${length(var.bosh_ports)}"
  vars {
    port = "${var.bosh_ports[count.index]}"
  }
}

data "template_file" "gorouter_port_group" {
  template = "${file("${var.template_dir}/router/components/port-group-entry.tpl")}"
  count    = "${length(var.bosh_ports)}"
  vars {
    port = "${var.bosh_ports[count.index]}"
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
  template = "${file("${var.template_dir}/router/components/port-group-entry.tpl")}"
  count    = "${length(var.tcp_router_ports)}"
  vars {
    port = "${var.tcp_router_ports[count.index]}"
  }
}

data "template_file" "vsphere_management_port_group" {
  template = "${file("${var.template_dir}/router/components/port-group-entry.tpl")}"
  count    = "${length(var.vsphere_management_ports)}"
  vars {
    port = "${var.vsphere_management_ports[count.index]}"
  }
}

data "template_file" "vcenter_management_port_group" {
  template = "${file("${var.template_dir}/router/components/port-group-entry.tpl")}"
  count    = "${length(var.vcenter_management_ports)}"
  vars {
    port = "${var.vcenter_management_ports[count.index]}"
  }
}

locals {
  router_fqdn = "${var.router_host}.${var.domain}"
  router_ip = "${cidrhost(local.local_cidr, 1)}"
  router_management_ip = "${cidrhost(local.management_cidr, 1)}"
  outside_fqdn = "${var.outside_host}.${var.domain}"
}

locals {
  vpn_start_address  = "${cidrhost(local.vpn_cidr, 10)}"
  vpn_end_address  = "${cidrhost(local.vpn_cidr, 50)}"
}

locals {
  gorouter_addresses = [
      "${cidrhost(local.deployment_cidr, -15)}",
      "${cidrhost(local.deployment_cidr, -14)}",
      "${cidrhost(local.deployment_cidr, -13)}"
    ]
  brain_addresses = [
      "${cidrhost(local.deployment_cidr, -10)}",
      "${cidrhost(local.deployment_cidr, -9)}",
      "${cidrhost(local.deployment_cidr, -8)}"
    ]
  tcp_router_addresses = [
      "${cidrhost(local.deployment_cidr, -5)}",
      "${cidrhost(local.deployment_cidr, -4)}",
      "${cidrhost(local.deployment_cidr, -3)}"
    ]
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
    local_cidr = "${local.local_cidr}"
    local_dhcp_start_addr = "${cidrhost(local.local_cidr, 10)}"
    local_dhcp_end_addr = "${cidrhost(local.local_cidr, 50)}"

    /* dns - can't use a list in a template */
    primary_dns_server  = "${var.dns_servers[0]}"
    secondary_dns_server = "${var.dns_servers[1]}"

    /* infrastructure networks */
    management_cidr = "${local.management_cidr}"
    management_port_ip = "${cidrhost(local.management_cidr,1)}"
    management_interface_addr = "${replace(local.management_cidr, cidrhost(local.management_cidr,0), cidrhost(local.management_cidr,1))}"
    management_dhcp_start_addr = "${cidrhost(local.local_cidr, 10)}"
    management_dhcp_end_addr = "${cidrhost(local.local_cidr, 50)}"
    vmware_cidr = "${local.vmware_cidr}"
    vmware_port_ip = "${cidrhost(local.vmware_cidr,1)}"
    vmware_interface_addr = "${replace(local.vmware_cidr, cidrhost(local.vmware_cidr,0), cidrhost(local.vmware_cidr,1))}"
    vsphere_ip = "${local.vsphere_ip}"
    bootstrap_cidr = "${local.bootstrap_cidr}"
    bootstrap_port_ip = "${cidrhost(local.bootstrap_cidr,1)}"
    bootstrap_interface_addr = "${replace(local.bootstrap_cidr, cidrhost(local.bootstrap_cidr,0), cidrhost(local.bootstrap_cidr,1))}"

    /* load balancer network */
    balancer_external_cidr = "${local.balancer_external_cidr}"
    balancer_external_port_ip = "${cidrhost(local.balancer_external_cidr,1)}"
    balancer_external_interface_addr = "${replace(local.balancer_external_cidr, cidrhost(local.balancer_external_cidr,0), cidrhost(local.balancer_external_cidr,1))}"
    balancer_internal_cidr = "${local.balancer_internal_cidr}"
    balancer_internal_port_ip = "${cidrhost(local.balancer_internal_cidr,1)}"
    balancer_internal_interface_addr = "${replace(local.balancer_internal_cidr, cidrhost(local.balancer_internal_cidr,0), cidrhost(local.balancer_internal_cidr,1))}"


    /* PCF network addresses */
    pcf_port_ip = "${cidrhost(local.pcf_cidr,1)}"
    pcf_interface_addr = "${replace(local.pcf_cidr, cidrhost(local.pcf_cidr,0), cidrhost(local.pcf_cidr,1))}"
    infrastructure_cidr = "${local.infrastructure_cidr}"
    infrastructure_port_ip = "${cidrhost(local.infrastructure_cidr,1)}"
    deployment_cidr = "${local.deployment_cidr}"
    deployment_port_ip = "${cidrhost(local.deployment_cidr,1)}"
    services_cidr = "${local.services_cidr}"
    services_port_ip = "${cidrhost(local.services_cidr,1)}"
    dynamic_cidr = "${local.dynamic_cidr}"
    dynamic_port_ip = "${cidrhost(local.dynamic_cidr,1)}"
    container_cidr = "${local.container_cidr}"
    container_port_ip = "${cidrhost(local.container_cidr,1)}"

    /* vpn */
    vpn_cidr = "${local.vpn_cidr}"
    vpn_psk = "${random_pet.vpn_psk.id}"
    vpn_users = "${join("          ", data.template_file.vpn_users.*.rendered)}"
    vpn_password = "${random_pet.vpn_password.id}"
    vpn_start_address = "${local.vpn_start_address}"
    vpn_end_address = "${local.vpn_end_address}"

    /* firewall */
    bosh_port_group = "${join("          ", data.template_file.bosh_port_group.*.rendered)}"
    gorouter_port_group = "${join("          ", data.template_file.gorouter_port_group.*.rendered)}"
    gorouter_address_group = "${join("          ", data.template_file.gorouter_address_group.*.rendered)}"
    brain_address_group = "${join("          ", data.template_file.brain_address_group.*.rendered)}"
    tcp_router_address_group = "${join("          ", data.template_file.tcp_router_address_group.*.rendered)}"
    tcp_router_port_group = "${join("          ", data.template_file.tcp_router_port_group.*.rendered)}"
    vsphere_management_port_group = "${join("          ", data.template_file.vsphere_management_port_group.*.rendered)}"
    vcenter_management_port_group = "${join("          ", data.template_file.vcenter_management_port_group.*.rendered)}"
  }

}

resource "local_file" "router_config" {
  content  = "${data.template_file.router_config.rendered}"
  filename = "${var.work_dir}/router/config.boot"


  provisioner "file" {
    content      = "${data.template_file.router_config.rendered}"
    destination  = "/tmp/config.boot"

    connection {
      type     = "ssh"
      user     = "ubnt"
      password = "uncontemporaneousness-insecure-nonclerical-menad"
      host     = "${local.router_fqdn}"
    }
  }
}
