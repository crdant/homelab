resource "acme_certificate" "prometheus" {
  account_key_pem           = "${acme_registration.letsencrypt.account_key_pem}"
  common_name               = "${local.prometheus_fqdn}"

  dns_challenge {
    provider = "gcloud"

    config {
      GCE_SERVICE_ACCOUNT_FILE = "${var.key_file}"
      GCE_PROJECT  = "${var.project}"
    }
  }
}

resource "local_file" "prometheus_certificate" {
  content  = "${acme_certificate.prometheus.certificate_pem}"
  filename = "${var.key_dir}/${acme_certificate.prometheus.certificate_domain}/cert.pem"
}

resource "local_file" "prometheus_private_key" {
  content  = "${acme_certificate.prometheus.private_key_pem}"
  filename = "${var.key_dir}/${acme_certificate.prometheus.certificate_domain}/privkey.pem"
}
