variable "pcf_concourse_team" {
  type = "string"
  default = "pivotal_cloud_foundry"
}

locals {
  pcf_team_secret_root = "/concourse/${var.pcf_concourse_team}"
}
