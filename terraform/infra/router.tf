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

/*
variable "vpn_config" {
  type = "map"
}

variable "users" {
  type = "list"
  default = [
    { name : "admin", password: "smalltalk"}
  ]
}
*/

/*
# networking



# static hosts

router_static_ips: [ ${router_static_ips} ]
tcp_router_static_ips: [ ${tcp_router_static_ips} ]
brain_static_ips: [ ${brain_static_ips} ]

  vpn_user: ${vpn_user}
  ssh_public_key: ${ssh_public_key}
  ssh_key_type: ${ssh_key_type}
  dns_servers: [ ${dns_servers} ]

OUTPUTS:
  router password (in credhub/vault?)
  vpn preshared key (in credhub/vault/1password)
  vpn password (in credhub/vault/1password)
  file:///${work_dir}/config.boot
  file:///${key_dir}/id_${router_user}
  file:///${ca_dir}/${router_host}/cert.pem
  file:///${ca_dir}/${router_host}/privkey.pem
  new router configuration (via SSH)

resource "template_dir" "router_config" {
  source_dir      = "${var.directories.templates}/router"
  destination_dir = "${var.directories.work}/router"

  vars {
    router_password: ${router_password}
    vpn_psk: ${vpn_psk}
    vpn_password: ${vpn_password}
    router_user: ${router_user}
    router_host: ${router_host}
    vpn_user: ${vpn_user}
    ssh_public_key: ${ssh_public_key}
    ssh_key_type: ${ssh_key_type}
    dns_servers: [ ${dns_servers} ]
    local_cidr: ${local_cidr}
    vpn_cidr: ${vpn_cidr}
    management_cidr: ${management_cidr}
    vmware_cidr: ${vmware_cidr}
    bootstrap_cidr: ${bootstrap_cidr}
    pcf_cidr: ${pcf_cidr}
    infrastructure_cidr: ${infrastructure_cidr}
    deployment_cidr: ${deployment_cidr}
    balancer_external_cidr: ${balancer_external_cidr}
    balancer_internal_cidr: ${balancer_internal_cidr}
    services_cidr: ${services_cidr}
    dynamic_cidr: ${dynamic_cidr}
    container_cidr: ${container_cidr}
    esxi_host: ${esxi_host}
    router_static_ips: [ ${router_static_ips} ]
    tcp_router_static_ips: [ ${tcp_router_static_ips} ]
    brain_static_ips: [ ${brain_static_ips} ]

    esxi_addr = `dig +short #{vars["esxi_host"]}`.rstrip

    vsphere_port_addr = IPAddr.new(vars["vmware_cidr"]).succ.to_cidr
    bootstrap_port_addr = IPAddr.new(vars["bootstrap_cidr"]).succ.to_cidr
    pcf_port_addr = IPAddr.new(vars["pcf_cidr"]).succ.to_cidr
    infrastructure_port_addr = IPAddr.new(vars["infrastructure_cidr"]).succ.to_cidr
    deployment_port_addr = IPAddr.new(vars["deployment_cidr"]).succ.to_cidr
    balancer_external_port_addr = IPAddr.new(vars["balancer_external_cidr"]).succ.to_cidr
    balancer_internal_port_addr = IPAddr.new(vars["balancer_internal_cidr"]).succ.to_cidr
    services_port_addr = IPAddr.new(vars["services_cidr"]).succ.to_cidr
    dynamic_port_addr = IPAddr.new(vars["dynamic_cidr"]).succ.to_cidr
    container_port_addr = IPAddr.new(vars["container_cidr"]).succ.to_cidr
    management_port_addr =  IPAddr.new(vars["management_cidr"]).succ.to_cidr
    vpn_start_addr = IPAddr.new(vars["vpn_cidr"]).add(38)
    vpn_end_addr = IPAddr.new(vars["vpn_cidr"]).add(50)
    local_router_addr = IPAddr.new(vars["local_cidr"]).to_s
    local_dhcp_start_addr = IPAddr.new(vars["local_cidr"]).add(38)
    local_dhcp_end_addr = IPAddr.new(vars["local_cidr"]).add(234)
    management_router_addr = IPAddr.new(vars["local_cidr"]).to_s
    management_dhcp_start_addr = IPAddr.new(vars["local_cidr"]).add(38)
    management_dhcp_end_addr = IPAddr.new(vars["local_cidr"]).add(234)
  }
}

<%
  vars = YAML::load_file("#{ENV["work_dir"]}/router_vars.yml")
  creds = YAML::load_file("#{ENV["key_dir"]}/router_creds.yml")
%>

*/
