locals {
  cluster_wildcard_ip = "${cidrhost(local.balancer_external_cidr,var.cluster_index + 1)}"
  cluster_wildcard_domain = "*.${local.cluster_fqdn}"
  cluster_default_wildcard_domain = "*.default.${local.cluster_fqdn}"
}

resource "google_dns_record_set" "cluster_wildcard" {
  name    = "${local.cluster_wildcard_domain}."
  type = "A"
  ttl  = "${var.dns_ttl}"

  managed_zone = "${data.google_dns_managed_zone.homelab.name}"

  rrdatas = [ "${local.cluster_wildcard_ip}" ]
}

resource "acme_certificate" "cluster_wildcard" {
  account_key_pem           = "${acme_registration.letsencrypt.account_key_pem}"
  common_name               = "${local.cluster_fqdn}"
  subject_alternative_names = [
    "${local.cluster_wildcard_domain}",
    "${local.cluster_default_wildcard_domain}"
  ]

  dns_challenge {
    provider = "gcloud"

    config {
      GCE_SERVICE_ACCOUNT_FILE = "${var.key_file}"
      GCE_PROJECT  = "${var.project}"
    }
  }
}

resource "local_file" "cluster_wildcard_certificate" {
  content  = "${acme_certificate.cluster_wildcard.certificate_pem}"
  filename = "${var.key_dir}/${acme_certificate.cluster_wildcard.certificate_domain}/wildcard-cert.pem"
}

resource "local_file" "cluster_wildcard_private_key" {
  content  = "${acme_certificate.cluster_wildcard.private_key_pem}"
  filename = "${var.key_dir}/${acme_certificate.cluster_wildcard.certificate_domain}/wildcard-privkey.pem"
}
