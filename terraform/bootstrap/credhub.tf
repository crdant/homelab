variable "credhub_host" {
  type = "string"
  default = "secrets"
}

variable "concourse_credhub_client" {
  type = "string"
  default = "concourse"
}

resource "random_pet" "credhub_encryption_password" {
  length = 6
}

resource "random_pet" "credhub_db_password" {
  length = 4
}

resource "random_pet" "credhub_uaa_users_admin_password" {
  length = 4
}

resource "random_pet" "credhub_uaa_admin_password" {
  length = 4
}

resource "random_pet" "credhub_uaa_login_password" {
  length = 4
}

resource "random_pet" "credhub_uaa_admin_client_password" {
  length = 4
}

resource "random_pet" "credhub_uaa_admin_user_password" {
  length = 4
}

resource "random_pet" "credhub_uaa_encryption_password" {
  length = 4
}

resource "random_pet" "concourse_credhub_client_secret" {
  length = 4
}

resource "tls_private_key" "jumpbox_ssh_key" {
  algorithm   = "RSA"
  rsa_bits    = 4096
}

data "template_file" "credhub_varfile" {
  template = "${file("${var.template_dir}/bootstrap/credhub-vars.yml")}"
  vars {
    credhub_encryption_password = "${random_pet.credhub_encryption_password.id}"
    database_admin = "${random_pet.credhub_db_password.id}"
    uaa_users_admin = "${random_pet.credhub_uaa_users_admin_password.id}"
    uaa_admin  = "${random_pet.credhub_uaa_admin_password.id}"
    uaa_login = "${random_pet.credhub_uaa_login_password.id}"
    credhub_admin_client_password = "${random_pet.credhub_admin_client_password.id}"
    credhub_admin_user_password = "${random_pet.credhub_admin_user_password.id}"
    jumpbox_ssh_private_key = "${tls_private_key.jumpbox_ssh_key.private_key_pem}"
    jumpbox_ssh_public_key = "${tls_private_key.jumpbox_ssh_key.public_key_openssh}"
    uaa_encryption_password = "${random_pet.credhub_uaa_encryption.id}"
  }
}

resource "local_file" "credhub_varfile" {
  content  = "${data.template_file.credhub_varfile.rendered}"
  filename = "${var.work_dir}/bootstrap/credhub-vars.yml"
}

resource "local_file" "credhub_manifest" {
  content  = "${data.template_file.credhub_manifest.rendered}"
  filename = "${var.work_dir}/bootstrap/credhub-vars.yml"
}

output "credhub_uaa_users_admin_password" {
  length = "${random_pet.credhub_uaa_users_admin_password.id}"
  sensitive = true
}

output "credhub_uaa_admin_password" {
  length = "${random_pet.credhub_uaa_admin_password.id}"
  sensitive = true
}

output "credhub_uaa_admin_password" {
  length = "${random_pet.credhub_uaa_login_password.id}"
  sensitive = true
}

output "credhub_uaa_admin_password" {
  length = "${random_pet.credhub_uaa_admin_client_password.id}"
  sensitive = true
}

output "credhub_uaa_admin_password" {
  length = "${random_pet.credhub_uaa_admin_user_password.id}"
  sensitive = true
}
