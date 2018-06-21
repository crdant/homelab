provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.region}"
}

variable "dns_ttl" {
  type = "string"
}

locals {
  router_alias = "router.${var.domain}"
  host_alias = "esxi.${var.domain}"
  vcenter_alias = "vcenter.${var.domain}"
}

resource "aws_route53_zone" "homelab" {
  name = "${var.domain}"
}

resource "aws_route53_record" "router" {
  zone_id = "${aws_route53_zone.homelab.zone_id}"
  name    = "${local.router_fqdn}"
  type    = "A"
  ttl     = "${var.dns_ttl}"
  records = [
    "${local.router_ip}"
  ]
}

resource "aws_route53_record" "router_alias" {
  zone_id = "${aws_route53_zone.homelab.zone_id}"
  name    = "${local.host_alias}"
  type    = "CNAME"
  ttl     = "${var.dns_ttl}"
  records = [
    "${local.router_fqdn}"
  ]
}

resource "aws_route53_record" "host" {
  zone_id = "${aws_route53_zone.homelab.zone_id}"
  name    = "${local.host_fqdn}"
  type    = "A"
  ttl     = "${var.dns_ttl}"
  records = [
    "${local.host_ip}"
  ]
}

resource "aws_route53_record" "host_alias" {
  zone_id = "${aws_route53_zone.homelab.zone_id}"
  name    = "${local.host_alias}"
  type    = "CNAME"
  ttl     = "${var.dns_ttl}"
  records = [
    "${local.host_fqdn}"
  ]
}

resource "aws_route53_record" "vcenter" {
  zone_id = "${aws_route53_zone.homelab.zone_id}"
  name    = "${local.vcenter_fqdn}"
  type    = "A"
  ttl     = "${var.dns_ttl}"
  records = [
    "${local.vcenter_ip}"
  ]
}

resource "aws_route53_record" "vcenter_alias" {
  zone_id = "${aws_route53_zone.homelab.zone_id}"
  name    = "${local.vcenter_alias}"
  type    = "CNAME"
  ttl     = "${var.dns_ttl}"
  records = [
    "${local.vcenter_fqdn}"
  ]
}
