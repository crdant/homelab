variable "concourse_host" {
  type = "string"
  default = "concourse"
}

variable "concourse_deployment" {
  type = "string"
  default = "concourse"
}

variable "concourse_github_client" {
  type = "string"
}

variable "concourse_github_secret {
  type = "string"
}

variable "concourse_main_github_user" {
  type = "string"
  default = "${var.user}"
}

variable "concourse_tls_port" {
  type = "string"
  default = "443"
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

data "template_file" "concourse_varfile" {
  template = "${file("${var.template_dir}/bootstrap/concourse-vars.yml")}"

  vars {
    # from the example CLI
    concourse_deployment = "${var.concourse_deployment}"
    web_ip = "${local.concourse_ip}"
    external_url: "https://${local.concourse_fqdn}"
    network_name: "${data.terraform_remote_state.pave.bootstrap_network"

    # from the cluster manifest
    postgres_password = ${random_pet.concourse_db_password.id}
    token_signing_private_key = "${tls_private_key.token_signing_keyprivate_key_pem}"
    token_signing_public_key = "${tls_private_key.token_signing_key.public_key_pem}"
    tsa_host_public_key = "${tls_private_key.tsa_host_key.private_key_pem}"
    tsa_host_private_key = "${tls_private_key.tsa_host_key.public_key_openssh}"
    worker_public_key = "${tls_private_key.worker_key.private_key_pem}"
    worker_private_key = "${tls_private_key.worker_key.public_key_openssh}"

    # credhub ops file
    credhub_credhub_url = "${local.credhub_fqdn}"
    credhub_client_id = "${var.concourse_credhub_client}"
    credhub_client_secret = "${random_pet.concourse_credhub_client_secret.id}"
    credhub_certificate = "${acme_certificate.credhub.certificate_pem}"

    # tls ops files
    concourse_tls_port = "${var.concourse_tls_port}"
    concourse_tls_certificate = "${concourse_tls_certificate}"
    concourse_tls_private_key ="${concourse_tls_private_key}"

    # for github auth ops file
    concourse_github_client = "${var.concourse_github_client}"
    concourse_github_secret = "${var.concourse_github_secret}"
    concourse_main_github_user = "${var.concourse_main_github_user}"
  }
}

resource "local_file" "concourse_varfile" {
  content  = "${data.template_file.concourse_varfile.rendered}"
  filename = "${var.work_dir}/bootstrap/concourse-vars.yml"
}

output "concourse_ip" {
  value = "${local.concourse_ip}"
}
