variable "vsphere_user" {
  type = "string"
}

variable "vsphere_password" {
  type = "string"
}

variable "vsphere_host" {
  type = "string"
}

variable "datacenter" {
  type = "string"
  default = "homelab"
}

variable "cluster" {
  type = "string"
  default = "homelab_primary"
}

variable "resource_pools" {
  type = "list"
  default = [ "zone-1", "zone-2", "zone-3" ]
}

locals {
  vsphere_fqdn = "${var.vsphere_host}.${var.domain}"
}

resource "vsphere_datacenter" "homelab" {
  name = "${var.datacenter}"
}

data "vsphere_datacenter" "homelab" {
  name = "${var.datacenter}"
}

resource "vsphere_compute_cluster" "homelab" {
  name = "${var.cluster}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"

  drs_enabled          = true
}

data "vsphere_compute_cluster" "homelab" {
  name          = "${var.cluster}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

resource "vsphere_resource_pool" "zones" {
  count = "${length(var.resource_pools)}"
  name = "zone-${count.index}"
  parent_resource_pool_id = "${data.vsphere_compute_cluster.homelab.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "${var.cluster}/Resources"
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
