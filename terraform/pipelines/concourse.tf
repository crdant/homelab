variable "pcf_concourse_team" {
  type = "string"
  default = "pivotal_cloud_foundry"
}

variable "om_install_pipeline" {
  type = "string"
  default = "deploy-opsman"
}

variable "pas_install_pipeline" {
  type = "string"
  default = "deploy-pas"
}

variable "pas_upgrade_pipeline" {
  type = "string"
  default = "upgrade-pas"
}

variable "om_upgrade_pipeline" {
  type = "string"
  default = "upgrade-opsman"
}

locals {
  pcf_team_secret_root = "/concourse/${var.pcf_concourse_team}"
}

locals {
  install_om_secret_root = "${local.pcf_team_secret_root}/${var.om_install_pipeline}"
  install_pas_secret_root = "${local.pcf_team_secret_root}/${var.pas_install_pipeline}"
  upgrade_pas_secret_root = "${local.pcf_team_secret_root}/${var.pas_upgrade_pipeline}"
  upgrade_om_secret_root = "${local.pcf_team_secret_root}/${var.om_upgrade_pipeline}"
}
