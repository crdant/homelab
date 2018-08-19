variable "vcenter_password" {
  type = "string"
}

variable "state_bucket" {
  type = "string"
}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
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
  backend "s3" {
    bucket = "${var.state_bucket}"
    key    = "pave"
    region = "${var.aws_region}"
  }
}

data "terraform_remote_state" "infra" {
  backend = "s3"

  config {
    bucket = "${var.state_bucket}"
    key    = "infra"
    region = "${var.aws_region}"
  }
}
