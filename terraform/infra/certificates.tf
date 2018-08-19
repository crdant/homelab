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
    provider = "gcloud"

    config {
      credentials = "${file("${var.key_file}")}"
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

resource "acme_certificate" "esxi" {
  account_key_pem           = "${acme_registration.letsencrypt.account_key_pem}"
  common_name               = "${local.vsphere_fqdn}"
  subject_alternative_names = [
    "${local.vsphere_alias}"
  ]

  dns_challenge {
    provider = "gcloud"

    config {
      credentials = "${file("${var.key_file}")}"
    }
  }

  provisioner "file" {
    content      = "${acme_certificate.esxi.certificate_pem}"
    destination  = "/etc/vmware/ssl/rui.crt"

    connection {
      type     = "ssh"
      user     = "${var.vsphere_user}"
      password = "${var.vsphere_password}"
      host     = "${local.vsphere_fqdn}"
    }
  }

  provisioner "file" {
    content      = "${acme_certificate.esxi.private_key_pem}"
    destination  = "/etc/vmware/ssl/rui.key"

    connection {
      type     = "ssh"
      user     = "${var.vsphere_user}"
      password = "${var.vsphere_password}"
      host     = "${local.vsphere_fqdn}"
    }
  }
}

resource "local_file" "esxi_certificate" {
  content  = "${acme_certificate.esxi.certificate_pem}"
  filename = "${var.key_dir}/${acme_certificate.esxi.certificate_domain}/cert.pem"
}

resource "local_file" "esxi_private_key" {
  content  = "${acme_certificate.esxi.private_key_pem}"
  filename = "${var.key_dir}/${acme_certificate.esxi.certificate_domain}/privkey.pem"
}

resource "acme_certificate" "vcenter" {
  account_key_pem           = "${acme_registration.letsencrypt.account_key_pem}"
  common_name               = "${local.vcenter_fqdn}"
  subject_alternative_names = [
    "${local.vcenter_alias}"
  ]

  dns_challenge {
    provider = "gcloud"

    config {
      credentials = "${file("${var.key_file}")}"
    }
  }
}

resource "local_file" "vcenter_certificate" {
  content  = "${acme_certificate.vcenter.certificate_pem}"
  filename = "${var.key_dir}/${acme_certificate.vcenter.certificate_domain}/cert.pem"
}

resource "local_file" "vcenter_private_key" {
  content  = "${acme_certificate.vcenter.private_key_pem}"
  filename = "${var.key_dir}/${acme_certificate.vcenter.certificate_domain}/privkey.pem"
}
