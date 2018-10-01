variable "pcf_concourse_team" {
  type = "string"
  default = "pivotal_cloud_foundry"
}

variable "pcf_concourse_user" {
  type = "string"
  default = "pivot"
}

variable "om_install_pipeline" {
  type = "string"
  default = "deploy-opsman"
}

variable "om_upgrade_pipeline" {
  type = "string"
  default = "upgrade-opsman"
}

variable "harbor_install_pipeline" {
  type = "string"
  default = "deploy-harbor"
}

variable "harbor_upgrade_pipeline" {
  type = "string"
  default = "upgrade-harbor"
}

variable "pas_install_pipeline" {
  type = "string"
  default = "deploy-pas"
}

variable "pas_upgrade_pipeline" {
  type = "string"
  default = "upgrade-pas"
}

variable "pks_install_pipeline" {
  type = "string"
  default = "deploy-pks"
}

variable "pks_upgrade_pipeline" {
  type = "string"
  default = "upgrade-pks"
}

locals {
  pcf_team_secret_root = "/concourse/${var.pcf_concourse_team}"
}

locals {
  install_om_secret_root = "${local.pcf_team_secret_root}/${var.om_install_pipeline}"
  upgrade_om_secret_root = "${local.pcf_team_secret_root}/${var.om_upgrade_pipeline}"
}

locals {
  install_pas_secret_root = "${local.pcf_team_secret_root}/${var.pas_install_pipeline}"
  upgrade_pas_secret_root = "${local.pcf_team_secret_root}/${var.pas_upgrade_pipeline}"
}

locals {
  install_harbor_secret_root = "${local.pcf_team_secret_root}/${var.harbor_install_pipeline}"
  upgrade_harbor_secret_root = "${local.pcf_team_secret_root}/${var.harbor_upgrade_pipeline}"
}

locals {
  install_pks_secret_root = "${local.pcf_team_secret_root}/${var.pks_install_pipeline}"
  upgrade_pks_secret_root = "${local.pcf_team_secret_root}/${var.pks_upgrade_pipeline}"
}

output "pcf_concourse_team" {
  value = "${var.pcf_concourse_team}"
}

output "om_install_pipeline" {
  value = "${var.om_install_pipeline}"
}

output "om_upgrade_pipeline" {
  value = "${var.om_upgrade_pipeline}"
}

output "harbor_install_pipeline" {
  value = "${var.harbor_install_pipeline}"
}

output "harbor_upgrade_pipeline" {
  value = "${var.harbor_upgrade_pipeline}"
}

resource "random_pet" "pcf_concourse_password" {
  length = 4
}

output "pcf_concourse_team" {
  value = "${var.pcf_concourse_team}"
}

output "pcf_concourse_user" {
  value = "${var.pcf_concourse_user}"
}

output "pcf_concourse_password" {
  value = "${random_pet.pcf_concourse_password.id}"
  sensitive = true
}
