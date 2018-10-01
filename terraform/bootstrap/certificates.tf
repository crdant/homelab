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

<<<<<<< Updated upstream
resource "acme_certificate" "balancer" {
  account_key_pem           = "${acme_registration.letsencrypt.account_key_pem}"
  common_name               = "${local.bigip_management_fqdn}"
  subject_alternative_names = [
    "${local.bigip_management_alias}"
  ]

  dns_challenge {
    provider = "gcloud"

    config {
      GCE_SERVICE_ACCOUNT_FILE = "${var.key_file}"
      GCE_PROJECT  = "${var.project}"
    }
  }
}

resource "local_file" "balancer_certificate" {
  content  = "${acme_certificate.balancer.certificate_pem}"
  filename = "${var.key_dir}/${acme_certificate.balancer.certificate_domain}/cert.pem"
}

resource "local_file" "balancer_private_key" {
  content  = "${acme_certificate.balancer.private_key_pem}"
  filename = "${var.key_dir}/${acme_certificate.balancer.certificate_domain}/privkey.pem"
}

=======
>>>>>>> Stashed changes
output "concourse_cert_file" {
  value = "${local_file.concourse_certificate.filename}"
}
