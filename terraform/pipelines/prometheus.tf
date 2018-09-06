variable "prometheus_host" {
  type = "string"
  default = "observe"
}

variable "prometheus_install_pipeline" {
  type = "string"
  default = "install-prometheus"
}

locals {
  prometheus_secret_root = "${local.pcf_team_secret_root}/${var.prometheus_install_pipeline}"
}

resource "random_pet" "prometheus_alert_manager_password" {
  length = 4
}

resource "random_pet" "prometheus_alert_mesh_password" {
  length = 4
}

resource "random_pet" "prometheus_password" {
  length = 4
}

resource "random_pet" "prometheus_db_grafana_password" {
  length = 4
}

resource "random_pet" "prometheus_grafana_password" {
  length = 4
}

resource "random_pet" "prometheus_grafana_secret_key" {
  length = 6
}

data "template_file" "prometheus_secrets" {
  template = "${file("${var.template_dir}/pipelines/prometheus-secrets.yml")}"
  vars {
    # from the manifest
    prometheus_secret_root = "${local.prometheus_secret_root}"
    prometheus_alert_manager_password = "${random_pet.prometheus_alert_manager_password.id}"
    prometheus_alert_mesh_password = "${random_pet.prometheus_alert_mesh_password.id}"
    prometheus_password = "${random_pet.prometheus_password.id}"
    prometheus_db_grafana_password = "${random_pet.prometheus_db_grafana_password.id}"
    prometheus_grafana_password = "${random_pet.prometheus_grafana_password.id}"
    prometheus_grafana_secret_key = "${random_pet.prometheus_grafana_secret_key.id}"
  }
}

resource "local_file" "prometheus_secrets" {
  content  = "${data.template_file.prometheus_secrets.rendered}"
  filename = "${var.key_dir}/pipelines/prometheus-secrets.yml"

  provisioner "local-exec" {
    command =<<COMMAND
eval "$(bbl print-env)"
credhub import --file ${self.filename}
COMMAND
  }
}

output "prometheus_password" {
  value = "${random_pet.prometheus_password.id}"
  sensitive = true
}

output "prometheus_grafana_password" {
  value = "${random_pet.prometheus_grafana_password.id}"
  sensitive = true
}
