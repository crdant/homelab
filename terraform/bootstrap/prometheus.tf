variable "prometheus_host" {
  type = "string"
  default = "observe"
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

data "template_file" "prometheus_varfile" {
  template = "${file("${var.template_dir}/bootstrap/prometheus-vars.yml")}"
  vars {
    # from the manifest
    prometheus_alert_manager_password = "${random_pet.prometheus_alert_manager_password.id}"
    prometheus_alert_mesh_password = "${random_pet.prometheus_alert_mesh_password.id}"
    prometheus_password = "${random_pet.prometheus_password.id}"
    prometheus_db_grafana_password = "${random_pet.prometheus_db_grafana_password.id}"
    prometheus_grafana_password = "${random_pet.prometheus_grafana_password.id}"
    prometheus_grafana_secret_key = "${random_pet.prometheus_grafana_secret_key.id}"
  }
}

resource "local_file" "prometheus_varfile" {
  content  = "${data.template_file.prometheus_varfile.rendered}"
  filename = "${var.work_dir}/bootstrap/prometheus-vars.yml"
}

resource "random_pet" "prometheus_password" {
  length = 4
}

resource "random_pet" "prometheus_grafana_password" {
  length = 4
}
