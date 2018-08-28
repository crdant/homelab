variable "vsan_switch" {
  type = "string"
  default = "vSAN"
}

variable "vsan_portgroup" {
  type = "string"
  default = "vSAN Network"
}

variable "bootstrap_switch" {
  type = "string"
  default = "bootstrap_switch"
}

variable "bootstrap_portgroup" {
  type = "string"
  default = "bootstrap"
}

variable "pcf_switch" {
  type = "string"
  default = "pcf_switch"
}

variable "infrastructure_portgroup" {
  type = "string"
  default = "infrastructure"
}

variable "deployment_portgroup" {
  type = "string"
  default = "deployment"
}

variable "services_portgroup" {
  type = "string"
  default = "services"
}

variable "pks_portgroup" {
  type = "string"
  default = "pks_clusters"
}

variable "load_balancer_internal_portgroup" {
  type = "string"
  default = "bigip_internal"
}

variable "load_balancer_external_portgroup" {
  type = "string"
  default = "bigip_external"
}

resource "vsphere_distributed_virtual_switch" "vsan" {
  name          = "${var.vsan_switch}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"

  uplinks         = [ "uplink1" ]
  active_uplinks  = [ "uplink1" ]
}

data "vsphere_network" "vsan" {
  name          = "${var.vsan_switch}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

resource "vsphere_distributed_port_group" "vsan" {
  name                            = "${var.vsan_portgroup}"
  distributed_virtual_switch_uuid = "${data.vsphere_network.vsan.id}"
}

resource "vsphere_distributed_virtual_switch" "bootstrap" {
  name          = "${var.bootstrap_switch}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"

  uplinks         = [ "uplink1" ]
  active_uplinks  = [ "uplink1" ]
}

data "vsphere_network" "bootstrap" {
  name          = "${var.bootstrap_switch}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

resource "vsphere_distributed_port_group" "bootstrap" {
  name                            = "${var.bootstrap_switch}"
  distributed_virtual_switch_uuid = "${data.vsphere_network.bootstrap.id}"
}

resource "vsphere_distributed_virtual_switch" "pcf" {
  name          = "${var.pcf_switch}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"

  uplinks         = [ "uplink1" ]
  active_uplinks  = [ "uplink1" ]
}

data "vsphere_network" "pcf" {
  name          = "${var.pcf_switch}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

resource "vsphere_distributed_port_group" "lb_internal" {
  name                            = "${var.load_balancer_internal_portgroup}"
  distributed_virtual_switch_uuid = "${data.vsphere_network.pcf.id}"
}

data "vsphere_network" "lb_internal" {
  name          = "${var.load_balancer_internal_portgroup}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

resource "vsphere_distributed_port_group" "lb_external" {
  name                            = "${var.load_balancer_external_portgroup}"
  distributed_virtual_switch_uuid = "${data.vsphere_network.pcf.id}"
}

data "vsphere_network" "lb_external" {
  name          = "${var.load_balancer_external_portgroup}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

resource "vsphere_distributed_port_group" "infrastructure" {
  name                            = "${var,infrastructure_portgroup}"
  distributed_virtual_switch_uuid = "${data.vsphere_network.pcf.id}"
}

data "vsphere_network" "infrastructure" {
  name          = "${var.infrastructure_portgroup}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

resource "vsphere_distributed_port_group" "deployment" {
  name                            = "${var.deployment_portgroup}"
  distributed_virtual_switch_uuid = "${data.vsphere_network.pcf.id}"
}

data "vsphere_network" "deployment" {
  name          = "${var.deployment_portgroup}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

resource "vsphere_distributed_port_group" "services" {
  name                            = "${var.services_portgroup}"
  distributed_virtual_switch_uuid = "${data.vsphere_network.pcf.id}"
}

data "vsphere_network" "services" {
  name          =  "${var.services_portgroup}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

resource "vsphere_distributed_port_group" "pks_clusters" {
  name                            = "${var.pks_portgroup}"
  distributed_virtual_switch_uuid = "${data.vsphere_network.pcf.id}"
}

data "vsphere_network" "pks_clusters" {
  name          = "${var.pks_portgroup}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}
