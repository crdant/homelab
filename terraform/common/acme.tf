provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

resource "tls_private_key" "letsencrypt" {
  algorithm = "RSA"
}

resource "acme_registration" "letsencrypt" {
  account_key_pem = "${tls_private_key.letsencrypt.private_key_pem}"
  email_address   = "${var.email}"
}
