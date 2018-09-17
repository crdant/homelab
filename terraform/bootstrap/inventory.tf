variable "homelab_folder" {
  type = "string"
  default = "homelab"
}

variable "hosts_folder" {
  type = "string"
  default = "hosts"
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

variable "pcf_disk_folder" {
  type = "string"
  default = "disks"
}

variable "pcf_template_folder" {
  type = "string"
  default = "pcf_templates"
}

resource "vsphere_folder" "hosts" {
  path          = "${var.hosts_folder}"
  type          = "host"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

resource "vsphere_folder" "infrastructure" {
  path          = "${var.infrastructure_folder}"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

resource "vsphere_folder" "bosh_templates" {
  path          = "${data.terraform_remote_state.pave.template_folder_name}/${var.bosh_template_folder}"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
  depends_on = [ "vsphere_folder.templates" ]
}

resource "vsphere_folder" "pcf_templates" {
  path          = "${data.terraform_remote_state.pave.template_folder_name}/${var.pcf_template_folder}"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
  depends_on = [ "vsphere_folder.templates" ]
}

resource "vsphere_folder" "bosh_bootloader" {
  path          = "${var.bbl_folder}"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

resource "vsphere_folder" "pivotal_cloud_foundry" {
  path          = "${var.pcf_folder}"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

output "opsman_vm_folder" {
  value = "/${data.vsphere_datacenter.homelab.name}/vm/${var.pcf_folder}"
}

output "infra_inventory_folder" {
  value = "/${data.vsphere_datacenter.homelab.name}/vm/${var.infrastructure_folder}"
}

output "pcf_inventory_folder" {
  value = "${data.vsphere_datacenter.homelab.name}/vm/${var.pcf_folder}"
}

output "pcf_template_folder" {
  value = "${data.vsphere_datacenter.homelab.name}/vm/${vsphere_folder.templates.path}/${var.pcf_template_folder}"
}

output "pcf_disk_folder" {
  value = "${var.pcf_folder}"
}
