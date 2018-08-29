variable "homelab_folder" {
  type = "string"
  default = "homelab"
}

variable "hosts_folder" {
  type = "string"
  default = "hosts"
}

variable "infrastructure_folder" {
  type = "string"
  default = "infrastructure"
}

variable "template_folder" {
  type = "string"
  default = "templates"
}

variable "bosh_template_folder" {
  type = "string"
  default = "bosh_templates"
}

variable "bbl_folder" {
  type = "string"
  default = "bosh_bootloader"
}

variable "pcf_folder" {
  type = "string"
  default = "pivotal_cloud_foundry"
}

variable "pcf_template_folder" {
  type = "string"
  default = "pcf_templates"
}

resource "vsphere_folder" "homelab" {
  path          = "${var.homelab_folder}"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

resource "vsphere_folder" "hosts" {
  path          = "${vsphere_folder.homelab.path}/${var.hosts_folder}"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

resource "vsphere_folder" "infrastructure" {
  path          = "${vsphere_folder.homelab.path}/${var.infrastructure_folder}"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

resource "vsphere_folder" "templates" {
  path          = "${vsphere_folder.homelab.path}/${var.template_folder}"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

resource "vsphere_folder" "bosh_templates" {
  path          = "${vsphere_folder.templates.path}/${var.bosh_template_folder}"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
  depends_on = [ "vsphere_folder.templates" ]
}

resource "vsphere_folder" "pcf_templates" {
  path          = "${vsphere_folder.templates.path}/${var.pcf_template_folder}"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
  depends_on = [ "vsphere_folder.templates" ]
}

resource "vsphere_folder" "bosh_bootloader" {
  path          = "${vsphere_folder.homelab.path}/${var.bbl_folder}"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

resource "vsphere_folder" "pivotal_cloud_foundry" {
  path          = "${vsphere_folder.homelab.path}/${var.pcf_folder}"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}
