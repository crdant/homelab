variable "bigip_external_ip" {
  type = "string"
}

data "google_dns_managed_zone" "homelab" {
  name     = "homelab"
}

resource "google_dns_record_set" "opsman" {
  name    = "${local.opsman_fqdn}."
  type = "A"
  ttl  = "${var.dns_ttl}"

  managed_zone = "${data.google_dns_managed_zone.homelab.name}"

  rrdatas = [ "${local.opsman_ip}" ]
}

resource "google_dns_record_set" "director" {
  name    = "${local.director_fqdn}."
  type = "A"
  ttl  = "${var.dns_ttl}"

  managed_zone = "${data.google_dns_managed_zone.homelab.name}"

  rrdatas = [ "${local.director_ip}" ]
}

resource "google_dns_record_set" "apps_domain" {
  name    = "${local.apps_domain_wildcard}."
  type = "A"
  ttl  = "${var.dns_ttl}"

  managed_zone = "${data.google_dns_managed_zone.homelab.name}"

  rrdatas = [ "${local.pas_wildcard_ip}" ]
}

resource "google_dns_record_set" "system_domain" {
  name    = "${local.system_domain_wildcard}."
  type = "A"
  ttl  = "${var.dns_ttl}"

  managed_zone = "${data.google_dns_managed_zone.homelab.name}"

  rrdatas = [ "${local.pas_wildcard_ip}" ]
}

resource "google_dns_record_set" "pas_ssh" {
  name    = "${local.pas_ssh_fqdn}."
  type = "A"
  ttl  = "${var.dns_ttl}"

  managed_zone = "${data.google_dns_managed_zone.homelab.name}"

  rrdatas = [ "${local.pas_ssh_ip}" ]
}

resource "google_dns_record_set" "pcf_ssh" {
  name    = "${local.tcprouter_fqdn}."
  type = "A"
  ttl  = "${var.dns_ttl}"

  managed_zone = "${data.google_dns_managed_zone.homelab.name}"

  rrdatas = [ "${local.tcp_router_ip}" ]
}

locals {
  prometheus_fqdn = "${var.prometheus_host}.${var.domain}"
}

resource "google_dns_record_set" "prometheus" {
  name    = "${local.prometheus_fqdn}."
  type = "A"
  ttl  = "${var.dns_ttl}"

  managed_zone = "${data.google_dns_managed_zone.homelab.name}"

  rrdatas = [ "${local.prometheus_ip}" ]
}

resource "google_dns_record_set" "mysql_proxy" {
  name    = "${local.mysql_proxy_fqdn}."
  type = "A"
  ttl  = "${var.dns_ttl}"

  managed_zone = "${data.google_dns_managed_zone.homelab.name}"

  rrdatas = "${local.pas_mysql_ips}"
}

resource "google_dns_record_set" "pks_api" {
  name    = "${local.pks_api_fqdn}."
  type = "A"
  ttl  = "${var.dns_ttl}"

  managed_zone = "${data.google_dns_managed_zone.homelab.name}"

  rrdatas = [ "${local.pks_wildcard_ip}" ]
}
