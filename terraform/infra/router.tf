variable "router_host" {
  type = "string"
}

locals {
  router_fqdn = "${var.router_host}.${var.domain}"
  router_ip = "${cidrhost(var.local_cidr, 1)}"
}

resource "random_pet" "vpn_psk" {
  size = 4
}

variable "router_password" {
  type = "string"
}
