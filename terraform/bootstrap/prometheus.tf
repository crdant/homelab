variable "prometheus_host" {
  type = "string"
  default = "observe"
}

data "template_file" "prometheus_varfile" {
  template = "${file("${var.template_dir}/bootstrap/prometheus-vars.yml")}"
  vars {

  }
}

resource "local_file" "prometheus_varfile" {
  content  = "${data.template_file.prometheus_varfile.rendered}"
  filename = "${var.work_dir}/bootstrap/prometheus-vars.yml"
}

data "template_file" "prometheus_manifest" {
  template = "${file("${var.template_dir}/bootstrap/prometheus-vars.yml")}"
  vars {

  }
}

resource "local_file" "prometheus_manifest" {
  content  = "${data.template_file.prometheus_manifest.rendered}"
  filename = "${var.work_dir}/bootstrap/prometheus-vars.yml"
}
