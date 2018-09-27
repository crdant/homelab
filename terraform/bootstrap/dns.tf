locals {
  concourse_fqdn = "${var.concourse_host}.${local.bootstrap_domain}"
}

data "google_dns_managed_zone" "homelab" {
  name     = "homelab"
}

resource "google_dns_record_set" "concourse" {
  name    = "${local.concourse_fqdn}."
  type = "A"
  ttl  = "${var.dns_ttl}"

  managed_zone = "${data.google_dns_managed_zone.homelab.name}"

  rrdatas = [ "${local.concourse_ip}" ]
}

resource "google_dns_record_set" "bigip_management" {
  name    = "${local.bigip_management_fqdn}."
  type = "A"
  ttl  = "${var.dns_ttl}"

  managed_zone = "${data.google_dns_managed_zone.homelab.name}"

  rrdatas = [ "${local.bigip_management_ip}" ]
}

resource "google_dns_record_set" "bigip_management_alias" {
  name = "${local.bigip_management_alias}."
  type = "CNAME"
  ttl  = "${var.dns_ttl}"

  managed_zone = "${data.google_dns_managed_zone.homelab.name}"

  rrdatas = [ "${local.bigip_management_fqdn}." ]
}
