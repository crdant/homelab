variable "vsphere_user" {
  type = "string"
}

variable "vsphere_password" {
  type = "string"
}

variable "vsphere_host" {
  type = "string"
}

locals {
  vsphere_fqdn = "${var.vsphere_host}.${var.domain}"
}

data "vsphere_datacenter" "homelab" {
  name = "homelab"
}

data "vsphere_compute_cluster" "homelab" {
  name          = "homelab"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

data "vsphere_resource_pool" "zone_1" {
  name = "zone-1"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

data "vsphere_resource_pool" "zone_2" {
  name = "zone-2"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

data "vsphere_resource_pool" "zone_3" {
  name = "zone-3"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

data "vsphere_network" "bootstrap" {
  name          = "bootstrap"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

data "vsphere_network" "lb_internal" {
  name          = "lb_internal"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

data "vsphere_network" "lb_external" {
  name          = "lb_external"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

data "vsphere_network" "infrastructure" {
  name          = "infrastructure"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

data "vsphere_network" "deployment" {
  name          = "deployment"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

data "vsphere_network" "services" {
  name          = "services"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

data "vsphere_network" "pks_clusters" {
  name          = "pks_clusters"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

/*
export BBL_VSPHERE_VCENTER_USER
export BBL_VSPHERE_VCENTER_PASSWORD
export BBL_VSPHERE_VCENTER_IP
export BBL_VSPHERE_VCENTER_DC
export BBL_VSPHERE_VCENTER_CLUSTER
export BBL_VSPHERE_VCENTER_RP
export BBL_VSPHERE_NETWORK
export BBL_VSPHERE_VCENTER_DS
export BBL_VSPHERE_SUBNET
*/
