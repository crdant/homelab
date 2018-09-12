resource "acme_certificate" "concourse" {
  account_key_pem           = "${acme_registration.letsencrypt.account_key_pem}"
  common_name               = "${local.concourse_fqdn}"

  dns_challenge {
    provider = "gcloud"

    config {
      GCE_SERVICE_ACCOUNT_FILE = "${var.key_file}"
      GCE_PROJECT  = "${var.project}"
    }
  }
}

resource "local_file" "concourse_certificate" {
  content  = "${acme_certificate.concourse.certificate_pem}"
  filename = "${var.key_dir}/${acme_certificate.concourse.certificate_domain}/cert.pem"
}

resource "local_file" "concourse_private_key" {
  content  = "${acme_certificate.concourse.private_key_pem}"
  filename = "${var.key_dir}/${acme_certificate.concourse.certificate_domain}/privkey.pem"
}

output "concourse_cert_file" {
  value = "${local_file.concourse_certificate.filename}"
}
