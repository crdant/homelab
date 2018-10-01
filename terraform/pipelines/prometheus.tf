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

resource "random_integer" "prometheus_availability_zone" {
  min     = 0
  max     = 2
}

resource "random_pet" "prometheus_password" {
  length = 4
}

resource "random_pet" "prometheus_grafana_password" {
  length = 4
}

resource "random_pet" "prometheus_alert_manager_password" {
  length = 4
}

resource "random_pet" "firehose_exporter_secret" {
  length = 6
}

resource "random_pet" "cf_exporter_secret" {
  length = 6
}

resource "random_pet" "bosh_exporter_secret" {
  length = 6
}

data "template_file" "prometheus_params" {
  template = "${file("${var.template_dir}/pipelines/prometheus/params.yml")}"
  vars {
    opsman_domain = "${local.opsman_fqdn}"
    network = "${data.terraform_remote_state.pave.deployment_network}"
    availability_zone_1 = "${var.availability_zones[random_integer.prometheus_availability_zone.result]}"
  }
}

resource "local_file" "prometheus_params" {
  content  = "${data.template_file.prometheus_params.rendered}"
  filename = "${var.work_dir}/pipelines/prometheus/params.yml"
}

data "template_file" "prometheus_secrets" {
  template = "${file("${var.template_dir}/pipelines/prometheus/secrets.yml")}"
  vars {
    prometheus_secret_root = "${local.prometheus_secret_root}"

    prometheus_password = "${random_pet.prometheus_password.id}"
    prometheus_grafana_password = "${random_pet.prometheus_grafana_password.id}"
    prometheus_alert_manager_password = "${random_pet.prometheus_alert_manager_password.id}"

    uaa_clients_firehose_exporter_secret = "${random_pet.firehose_exporter_secret.id}"
    uaa_clients_cf_exporter_secret = "${random_pet.cf_exporter_secret.id}"
    uaa_clients_bosh_exporter_secret = "${random_pet.bosh_exporter_secret.id}"
  }
}

resource "local_file" "prometheus_secrets" {
  content  = "${data.template_file.prometheus_secrets.rendered}"
  filename = "${var.key_dir}/pipelines/prometheus/secrets.yml"

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

output "prometheus_alert_manager_password" {
  value = "${random_pet.prometheus_alert_manager_password.id}"
  sensitive = true
}
