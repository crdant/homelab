variable "concourse_host" {
  type = "string"
  default = "concourse"
}

variable "concourse_deployment" {
  type = "string"
  default = "concourse"
}

# based on default BBL cloud config, which is the `bootstrap_network` value output from `pave`
variable "concourse_bosh_network_name" {
  type = "string"
  default = "default"
}

variable "concourse_github_client" {
  type = "string"
}

variable "concourse_github_secret" {
  type = "string"
}

variable "concourse_main_github_user" {
  type = "string"
}

variable "concourse_main_github_org" {
  type = "string"
}

variable "concourse_tls_port" {
  type = "string"
  default = "443"
}

variable "concourse_credhub_client_id" {
  type = "string"
  default = "concourse"
}

resource "random_pet" "concourse_db_password" {
  length = 4
}

resource "tls_private_key" "token_signing_key" {
  algorithm   = "RSA"
  rsa_bits    = 4096
}

resource "tls_private_key" "tsa_host_key" {
  algorithm   = "RSA"
  rsa_bits    = 4096
}

resource "tls_private_key" "worker_key" {
  algorithm   = "RSA"
  rsa_bits    = 4096
}

resource "random_pet" "concourse_credhub_client_secret" {
  length = 4
}

data "template_file" "concourse_varfile" {
  template = "${file("${var.template_dir}/bootstrap/concourse-vars.yml")}"

  vars {
    # from the example CLI
    concourse_deployment = "${var.concourse_deployment}"
    concourse_static_ip = "${local.concourse_ip}"
    concourse_url = "https://${local.concourse_fqdn}"
    concourse_network = "${var.concourse_bosh_network_name}"

    # from the cluster manifest
    postgres_password = "${random_pet.concourse_db_password.id}"
    token_signing_private_key = "${replace(tls_private_key.token_signing_key.private_key_pem, "\n", "\n    ")}"
    token_signing_public_key = "${replace(tls_private_key.token_signing_key.public_key_pem, "\n", "\n    ")}"
    tsa_host_public_key = "${replace(tls_private_key.tsa_host_key.private_key_pem, "\n", "\n    ")}"
    tsa_host_private_key = "${tls_private_key.tsa_host_key.public_key_openssh}"
    worker_public_key = "${tls_private_key.worker_key.public_key_openssh}"
    worker_private_key = "${replace(tls_private_key.worker_key.private_key_pem, "\n", "\n    ")}"

    # credhub ops file
    credhub_ip =  "${var.director_internal_ip}"
    credhub_client_id = "${var.concourse_credhub_client_id}"
    credhub_client_secret = "${random_pet.concourse_credhub_client_secret.id}"

    # tls ops files
    concourse_external_host = "${local.concourse_fqdn}"
    concourse_tls_port = "${var.concourse_tls_port}"
    concourse_tls_certificate = "${replace(acme_certificate.concourse.certificate_pem, "\n", "\n    ")}"
    concourse_tls_private_key = "${replace(acme_certificate.concourse.private_key_pem, "\n", "\n    ")}"

    # for github auth ops file
    concourse_github_client = "${var.concourse_github_client}"
    concourse_github_secret = "${var.concourse_github_secret}"
    concourse_main_github_user = "${var.concourse_main_github_user}"
    concourse_main_github_org = "${var.concourse_main_github_org}"
  }
}

resource "local_file" "concourse_varfile" {
  content  = "${data.template_file.concourse_varfile.rendered}"
  filename = "${var.work_dir}/bootstrap/concourse-vars.yml"
}

output "concourse_ip" {
  value = "${local.concourse_ip}"
}

output "concourse_credhub_client_secret" {
  value = "${random_pet.concourse_credhub_client_secret.id}"
}
