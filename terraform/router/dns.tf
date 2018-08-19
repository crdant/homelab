variable "dns_ttl" {
  type = "string"
}

locals {
  router_alias = "router.${var.domain}"
  vsphere_alias = "esxi.${var.domain}"
  vcenter_alias = "vcenter.${var.domain}"
  outside_alias = "pigeon.${var.domain}"
}

data "google_dns_managed_zone" "homelab" {
  name     = "crdant-net"
}

resource "google_dns_record_set" "router" {
  name    = "${local.router_fqdn}"
  type = "A"
  ttl  = "${var.dns_ttl}"

  managed_zone = "${data.google_dns_managed_zone.homelab.name}"

  rrdatas = [ "${local.router_management_ip}" ]
}

resource "google_dns_record_set" "router_alias" {
  name = "${local.router_alias}"
  type = "CNAME"
  ttl  = "${var.dns_ttl}"

  managed_zone = "${data.google_dns_managed_zone.homelab.name}"

  rrdatas = [ "${local.router_fqdn}" ]
}
resource "google_dns_record_set" "outside" {
  name    = "${local.outside_fqdn}"
  type = "A"
  ttl  = "${var.dns_ttl}"

  managed_zone = "${data.google_dns_managed_zone.homelab.name}"

  rrdatas = [ "73.218.219.226" ]
}

resource "google_dns_record_set" "outside_alias" {
  name = "${local.outside_alias}"
  type = "CNAME"
  ttl  = "${var.dns_ttl}"

  managed_zone = "${data.google_dns_managed_zone.homelab.name}"

  rrdatas = [ "${local.outside_fqdn}" ]
}
