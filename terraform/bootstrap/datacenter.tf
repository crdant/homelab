variable "datacenter" {
  type = "string"
  default = "homelab"
}

data "vsphere_datacenter" "homelab" {
  name = "${var.datacenter}"
}
