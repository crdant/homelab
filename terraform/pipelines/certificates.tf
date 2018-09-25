resource "acme_certificate" "pas_wildcard" {
  account_key_pem           = "${acme_registration.letsencrypt.account_key_pem}"
  common_name               = "${local.pas_subdomain}"
  subject_alternative_names = [
    "${local.apps_domain_wildcard}",
    "${local.system_domain_wildcard}",
    "*.login.${local.system_domain}",
    "*.uaa.${local.system_domain}"
  ]

  dns_challenge {
    provider = "gcloud"

    config {
      GCE_SERVICE_ACCOUNT_FILE = "${var.key_file}"
      GCE_PROJECT  = "${var.project}"
    }
  }
}

resource "local_file" "pas_wildcard_certificate" {
  content  = "${acme_certificate.pas_wildcard.certificate_pem}"
  filename = "${var.key_dir}/${acme_certificate.pas_wildcard.certificate_domain}/cert.pem"
}

resource "local_file" "pas_wildcard_private_key" {
  content  = "${acme_certificate.pas_wildcard.private_key_pem}"
  filename = "${var.key_dir}/${acme_certificate.pas_wildcard.certificate_domain}/privkey.pem"
}

resource "acme_certificate" "pks_wildcard" {
  account_key_pem           = "${acme_registration.letsencrypt.account_key_pem}"
  common_name               = "${local.pks_subdomain}"
  subject_alternative_names = [
    "${local.pks_domain_wildcard}"
  ]

  dns_challenge {
    provider = "gcloud"

    config {
      GCE_SERVICE_ACCOUNT_FILE = "${var.key_file}"
      GCE_PROJECT  = "${var.project}"
    }
  }
}

resource "local_file" "pks_wildcard_certificate" {
  content  = "${acme_certificate.pks_wildcard.certificate_pem}"
  filename = "${var.key_dir}/${acme_certificate.pks_wildcard.certificate_domain}/cert.pem"
}

resource "local_file" "pks_wildcard_private_key" {
  content  = "${acme_certificate.pks_wildcard.private_key_pem}"
  filename = "${var.key_dir}/${acme_certificate.pks_wildcard.certificate_domain}/privkey.pem"
}

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

resource "acme_certificate" "registry" {
  account_key_pem           = "${acme_registration.letsencrypt.account_key_pem}"
  common_name               = "${local.registry_fqdn}"

  dns_challenge {
    provider = "gcloud"

    config {
      GCE_SERVICE_ACCOUNT_FILE = "${var.key_file}"
      GCE_PROJECT  = "${var.project}"
    }
  }
}

resource "local_file" "registry_certificate" {
  content  = "${acme_certificate.registry.certificate_pem}"
  filename = "${var.key_dir}/${acme_certificate.registry.certificate_domain}/cert.pem"
}

resource "local_file" "registry_private_key" {
  content  = "${acme_certificate.registry.private_key_pem}"
  filename = "${var.key_dir}/${acme_certificate.registry.certificate_domain}/privkey.pem"
}
