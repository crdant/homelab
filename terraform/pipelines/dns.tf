locals {
  prometheus_fqdn = "${var.prometheus_host}.${var.domain}"
}

data "google_dns_managed_zone" "homelab" {
  name     = "homelab"
}

resource "google_dns_record_set" "prometheus" {
  name    = "${local.prometheus_fqdn}."
  type = "A"
  ttl  = "${var.dns_ttl}"

  managed_zone = "${data.google_dns_managed_zone.homelab.name}"

  rrdatas = [ "${local.prometheus_ip}" ]
}
