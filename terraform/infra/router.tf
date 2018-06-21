variable "router_host" {
  type = "string"
}

locals {
  router_fqdn = "${var.router_host}.${var.domain}"
  router_ip = "${cidrhost(var.local_cidr, 1)}"
}

resource "random_pet" "vpn_psk" {
  length = 4
}

variable "router_password" {
  type = "string"
}

resource "template_dir" "router_config" {
  source_dir      = "${var.template_dir}/router"
  destination_dir = "${var.work_dir}/router"

  vars {
    infrastructure_cidr = "${var.infrastructure_cidr}"
    deployment_cidr = "${var.deployment_cidr}"
    services_cidr = "${var.services_cidr}"
    dynamic_cidr = "${var.dynamic_cidr}"
    container_cidr = "${var.container_cidr}"
  }

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
