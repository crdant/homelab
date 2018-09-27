variable "pcf_apps_prefix" {
  type = "string"
  default = "apps"
}

variable "pcf_system_prefix" {
  type = "string"
  default = "system"
}

variable "pcf_tcp_prefix" {
  type = "string"
  default = "tcp"
}

variable "mysql_proxy_host" {
  type = "string"
  default = "mysql"
}

locals {
  pas_subdomain = "pas.${var.domain}"
  apps_domain = "${var.pcf_apps_prefix}.${local.pas_subdomain}"
  system_domain = "${var.pcf_system_prefix}.${local.pas_subdomain}"
  apps_domain_wildcard = "*.${local.apps_domain}"
  system_domain_wildcard = "*.${local.system_domain}"
  mysql_proxy_fqdn = "${var.mysql_proxy_host}.${local.pas_subdomain}"
}

locals {
  pks_subdomain = "pks.${var.domain}"
  pks_domain_wildcard = "*.${local.pks_subdomain}"
}
