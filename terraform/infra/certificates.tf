provider "acme" {
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

resource "tls_private_key" "letsencrypt" {
  algorithm = "RSA"
}

resource "acme_registration" "letsencrypt" {
  account_key_pem = "${tls_private_key.letsencrypt.private_key_pem}"
  email_address   = "${var.email}"
}

resource "acme_certificate" "router" {
  account_key_pem           = "${acme_registration.letsencrypt.account_key_pem}"
  common_name               = "${local.router_fqdn}"
  subject_alternative_names = [
    "${local.router_alias}"
  ]

  dns_challenge {
    provider = "route53"
  }
}

resource "acme_certificate" "esxi" {
  account_key_pem           = "${acme_registration.letsencrypt.account_key_pem}"
  common_name               = "${local.host_fqdn}"
  subject_alternative_names = [
    "${local.host_alias}"
  ]

  dns_challenge {
    provider = "route53"
  }
}

resource "acme_certificate" "vcenter" {
  account_key_pem           = "${acme_registration.letsencrypt.account_key_pem}"
  common_name               = "${local.vcenter_fqdn}"
  subject_alternative_names = [
    "${local.vcenter_alias}"
  ]

  dns_challenge {
    provider = "route53"
  }
}
