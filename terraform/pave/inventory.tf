variable "template_folder" {
  type = "string"
  default = "templates"
}

variable "bosh_template_folder" {
  type = "string"
  default = "bosh_templates"
}

variable "pcf_folder" {
  type = "string"
  default = "pivotal_cloud_foundry"
}

variable "pcf_template_folder" {
  type = "string"
  default = "pcf_templates"
}

resource "vsphere_folder" "templates" {
  path          = "${var.template_folder}"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

resource "vsphere_folder" "bosh_templates" {
  path          = "${var.template_folder}/${var.bosh_template_folder}"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
  depends_on = [ "vsphere_folder.templates" ]
}

resource "vsphere_folder" "pcf_templates" {
  path          = "${var.template_folder}/${var.pcf_template_folder}"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
  depends_on = [ "vsphere_folder.templates" ]
}

resource "vsphere_folder" "pivotal_cloud_foundry" {
  path          = "${var.pcf_folder}"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}
