locals {
  concourse_fqdn = "${var.concourse_host}.${var.domain}"
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
