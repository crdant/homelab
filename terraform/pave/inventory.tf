variable "homelab_folder" {
  type = "string"
  default = "homelab"
}

variable "infrastructure_folder" {
  type = "string"
  default = "infrastructure"
}

variable "template_folder" {
  type = "string"
  default = "templates"
}

resource "vsphere_folder" "infrastructure" {
  path          = "${var.infrastructure_folder}"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

resource "vsphere_folder" "templates" {
  path          = "${var.template_folder}"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

output "infrastructure_folder" {
  value = "/${data.vsphere_datacenter.homelab.name}/vm/${var.infrastructure_folder}"
}

output "template_folder_name" {
  value = "${var.template_folder}"
}

output "template_folder" {
  value = "/${data.vsphere_datacenter.homelab.name}/vm/${var.template_folder}"
}
