locals {
  vsphere_fqdn = "${var.vsphere_host}.${var.domain}"
  vcenter_fqdn = "${var.vcenter_host}.${var.domain}"
  vsphere_alias = "esxi.${var.domain}"
  vcenter_alias = "vcenter.${var.domain}"
}

data "google_dns_managed_zone" "homelab" {
  name     = "homelab"
}

resource "google_dns_record_set" "vsphere_alias" {
  name = "${local.vsphere_alias}."
  type = "CNAME"
  ttl  = "${var.dns_ttl}"

  managed_zone = "${data.google_dns_managed_zone.homelab.name}"

  rrdatas = [ "${local.vsphere_fqdn}." ]
}

resource "google_dns_record_set" "vcenter" {
  name    = "${local.vcenter_fqdn}."
  type = "A"
  ttl  = "${var.dns_ttl}"

  managed_zone = "${data.google_dns_managed_zone.homelab.name}"

  rrdatas = [ "${local.vcenter_server_ip}" ]
}

resource "google_dns_record_set" "vcenter_alias" {
  name = "${local.vcenter_alias}."
  type = "CNAME"
  ttl  = "${var.dns_ttl}"

  managed_zone = "${data.google_dns_managed_zone.homelab.name}"

  rrdatas = [ "${local.vcenter_fqdn}." ]
}
