provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

variable "dns_ttl" {
  type = "string"
}

locals {
  router_alias = "router.${var.domain}"
  vsphere_alias = "esxi.${var.domain}"
  vcenter_alias = "vcenter.${var.domain}"
  outside_alias = "pigeon.${var.domain}"
}

resource "aws_route53_zone" "homelab" {
  name = "${var.domain}"
  comment = "PCF Home Lab"
}

resource "aws_route53_record" "router" {
  zone_id = "${aws_route53_zone.homelab.zone_id}"
  name    = "${local.router_fqdn}"
  type    = "A"
  ttl     = "${var.dns_ttl}"
  records = [
    "${local.router_management_ip}"
  ]
}

resource "aws_route53_record" "router_alias" {
  zone_id = "${aws_route53_zone.homelab.zone_id}"
  name    = "${local.router_alias}"
  type    = "CNAME"
  ttl     = "${var.dns_ttl}"
  records = [
    "${local.router_fqdn}"
  ]
}

resource "aws_route53_record" "vsphere" {
  zone_id = "${aws_route53_zone.homelab.zone_id}"
  name    = "${local.vsphere_fqdn}"
  type    = "A"
  ttl     = "${var.dns_ttl}"
  records = [
    "${local.vsphere_ip}"
  ]
}

resource "aws_route53_record" "vsphere_alias" {
  zone_id = "${aws_route53_zone.homelab.zone_id}"
  name    = "${local.vsphere_alias}"
  type    = "CNAME"
  ttl     = "${var.dns_ttl}"
  records = [
    "${local.vsphere_fqdn}"
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

resource "aws_route53_record" "outside" {
  zone_id = "${aws_route53_zone.homelab.zone_id}"
  name    = "${local.outside_fqdn}"
  type    = "A"
  ttl     = "${var.dns_ttl}"
  records = [
    "73.218.219.226"
  ]
}

resource "aws_route53_record" "outside_alias" {
  zone_id = "${aws_route53_zone.homelab.zone_id}"
  name    = "${local.vcenter_alias}"
  type    = "CNAME"
  ttl     = "${var.dns_ttl}"
  records = [
    "${local.vcenter_fqdn}"
  ]
}
