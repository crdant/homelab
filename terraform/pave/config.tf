variable "vcenter_password" {
  type = "string"
}

variable "state_bucket" {
  type = "string"
}

provider "vsphere" {
  alias = "vcenter"
  user           = "${var.vcenter_user}"
  password       = "${var.vcenter_password}"
  vsphere_server = "${local.vcenter_fqdn}"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

terraform {
  backend "gcs" {
    prefix = "pave"
  }
}

data "terraform_remote_state" "infra" {
  backend "gcs" {
    prefix = "infra"
  }
}
