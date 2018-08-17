provider "vsphere" {
  alias = "esxi"
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"
  vsphere_server = "${local.vsphere_fqdn}"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

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
  vsphere_ip = "${cidrhost(local.vmware_cidr, 10)}"
}

data "vsphere_datacenter" "default" {
  provider = "vsphere.esxi"
}

data "vsphere_resource_pool" "root" {
  provider = "vsphere.esxi"
}

data "vsphere_host" "physical" {
  datacenter_id = "${data.vsphere_datacenter.default.id}"
  provider = "vsphere.esxi"
}

data "vsphere_vmfs_disks" "ssd" {
  host_system_id = "${data.vsphere_host.physical.id}"
  rescan         = true
  filter         = "Crucial_CT1050MX300SSD4"
  provider = "vsphere.esxi"
}

data "vsphere_vmfs_disks" "spinning" {
  host_system_id = "${data.vsphere_host.physical.id}"
  rescan         = true
  filter         = "ST4000LM0242D2AN17V"
  provider = "vsphere.esxi"
}

resource "null_resource" "vsan_policy" {
  provisioner "remote-exec" {
    inline = [
      "esxcli vsan policy setdefault -c vdisk -p \"((\\\"hostFailuresToTolerate\\\" i1) (\\\"forceProvisioning\\\" i1))\"",
      "esxcli vsan policy setdefault -c vmnamespace -p \"((\\\"hostFailuresToTolerate\\\" i1) (\\\"forceProvisioning\\\" i1))\""
    ]
    connection {
      type     = "ssh"
      user     = "${var.vsphere_user}"
      password = "${var.vsphere_password}"
      host = "${local.vsphere_fqdn}"
    }
  }
}

resource "null_resource" "vsan_cluster" {
  provisioner "remote-exec" {
    inline = [
      "esxcli vsan cluster new",
      "esxcli vsan storage add -s ${data.vsphere_vmfs_disks.ssd.disks.0} -d ${data.vsphere_vmfs_disks.spinning.disks.0}"
    ]
    connection {
      type     = "ssh"
      user     = "${var.vsphere_user}"
      password = "${var.vsphere_password}"
      host = "${local.vsphere_fqdn}"
    }
  }
}
