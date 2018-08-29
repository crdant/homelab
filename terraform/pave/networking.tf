variable "vsan_switch" {
  type = "string"
  default = "vSAN"
}

variable "vsan_nic" {
  type = "string"
  default = "vmnic1"
}

variable "vsan_portgroup" {
  type = "string"
  default = "vSAN Network"
}

variable "bootstrap_switch" {
  type = "string"
  default = "bootstrap_switch"
}

variable "bootstrap_nic" {
  type = "string"
  default = "vmnic2"
}

variable "bootstrap_portgroup" {
  type = "string"
  default = "bootstrap"
}

variable "pcf_switch" {
  type = "string"
  default = "pcf_switch"
}

variable "pcf_nic" {
  type = "string"
  default = "vmnic3"
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

  host {
    host_system_id = "${data.vsphere_host.homelab.id}"
    devices        = [ "${var.vsan_nic}" ]
  }

}

data "vsphere_distributed_virtual_switch" "vsan" {
  name          = "${vsphere_distributed_virtual_switch.vsan.name}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
  depends_on    = [ "vsphere_distributed_virtual_switch.vsan" ]
}

resource "vsphere_distributed_port_group" "vsan" {
  name                            = "${var.vsan_portgroup}"
  distributed_virtual_switch_uuid = "${data.vsphere_distributed_virtual_switch.vsan.id}"
}

resource "vsphere_distributed_virtual_switch" "bootstrap" {
  name          = "${var.bootstrap_switch}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"

  uplinks         = [ "uplink1" ]
  active_uplinks  = [ "uplink1" ]

  host {
    host_system_id = "${data.vsphere_host.homelab.id}"
    devices        = [ "${var.bootstrap_nic}" ]
  }

}

data "vsphere_distributed_virtual_switch" "bootstrap" {
  name          = "${vsphere_distributed_virtual_switch.bootstrap.name}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
  depends_on    = [ "vsphere_distributed_virtual_switch.bootstrap" ]

}

resource "vsphere_distributed_port_group" "bootstrap" {
  name                            = "${var.bootstrap_portgroup}"
  distributed_virtual_switch_uuid = "${data.vsphere_distributed_virtual_switch.bootstrap.id}"
}

data "vsphere_network" "bootstrap" {
  name          = "${vsphere_distributed_port_group.bootstrap.name}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
  depends_on    = [ "vsphere_distributed_port_group.bootstrap" ]
}

resource "vsphere_distributed_virtual_switch" "pcf" {
  name          = "${var.pcf_switch}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"

  uplinks         = [ "uplink1" ]
  active_uplinks  = [ "uplink1" ]

  host {
    host_system_id = "${data.vsphere_host.homelab.id}"
    devices        = [ "${var.pcf_nic}" ]
  }
}

data "vsphere_distributed_virtual_switch" "pcf" {
  name          = "${vsphere_distributed_virtual_switch.pcf.name}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
  depends_on    = [ "vsphere_distributed_virtual_switch.pcf" ]
}

resource "vsphere_distributed_port_group" "lb_internal" {
  name                            = "${var.load_balancer_internal_portgroup}"
  distributed_virtual_switch_uuid = "${data.vsphere_distributed_virtual_switch.pcf.id}"
}

data "vsphere_network" "lb_internal" {
  name          = "${vsphere_distributed_port_group.lb_internal.name}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
  depends_on    = [ "vsphere_distributed_port_group.lb_internal" ]
}

resource "vsphere_distributed_port_group" "lb_external" {
  name                            = "${var.load_balancer_external_portgroup}"
  distributed_virtual_switch_uuid = "${data.vsphere_distributed_virtual_switch.pcf.id}"
}

data "vsphere_network" "lb_external" {
  name          = "${vsphere_distributed_port_group.lb_external.name}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
  depends_on    = [ "vsphere_distributed_port_group.lb_external" ]
}

resource "vsphere_distributed_port_group" "infrastructure" {
  name                            = "${var.infrastructure_portgroup}"
  distributed_virtual_switch_uuid = "${data.vsphere_distributed_virtual_switch.pcf.id}"
}

data "vsphere_network" "infrastructure" {
  name          = "${vsphere_distributed_port_group.infrastructure.name}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
  depends_on    = [ "vsphere_distributed_port_group.infrastructure" ]
}

resource "vsphere_distributed_port_group" "deployment" {
  name                            = "${var.deployment_portgroup}"
  distributed_virtual_switch_uuid = "${data.vsphere_distributed_virtual_switch.pcf.id}"
}

data "vsphere_network" "deployment" {
  name          = "${vsphere_distributed_port_group.deployment.name}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
  depends_on    = [ "vsphere_distributed_port_group.deployment" ]
}

resource "vsphere_distributed_port_group" "services" {
  name                            = "${var.services_portgroup}"
  distributed_virtual_switch_uuid = "${data.vsphere_distributed_virtual_switch.pcf.id}"
}

data "vsphere_network" "services" {
  name          = "${vsphere_distributed_port_group.services.name}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
  depends_on    = [ "vsphere_distributed_port_group.services" ]
}

resource "vsphere_distributed_port_group" "pks_clusters" {
  name                            = "${var.pks_portgroup}"
  distributed_virtual_switch_uuid = "${data.vsphere_distributed_virtual_switch.pcf.id}"
}

data "vsphere_network" "pks_clusters" {
  name          = "${vsphere_distributed_port_group.pks_clusters.name}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
  depends_on    = [ "vsphere_distributed_port_group.pks_clusters" ]
}
