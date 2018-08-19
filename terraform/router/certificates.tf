resource "acme_certificate" "router" {
  account_key_pem           = "${acme_registration.letsencrypt.account_key_pem}"
  common_name               = "${local.router_fqdn}"
  subject_alternative_names = [
    "${local.router_alias}"
  ]

  dns_challenge {
    provider = "gcloud"

    config {
      GCE_SERVICE_ACCOUNT_FILE = "${var.key_file}"
      GCE_PROJECT  = "${var.project}"
    }
  }
}

resource "local_file" "router_certificate" {
  content  = "${acme_certificate.router.certificate_pem}"
  filename = "${var.key_dir}/${acme_certificate.router.certificate_domain}/cert.pem"
}

resource "local_file" "router_private_key" {
  content  = "${acme_certificate.router.private_key_pem}"
  filename = "${var.key_dir}/${acme_certificate.router.certificate_domain}/privkey.pem"
}
