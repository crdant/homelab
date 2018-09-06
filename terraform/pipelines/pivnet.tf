variable "pivnet_token" {
  type = "string"
}

data "template_file" "prometheus_secrets" {
  template = "${file("${var.template_dir}/pivotalcf/pivnet-secrets.yml")}"
  vars {
    # from the manifest
    pcf_team_secret_root = "${local.pcf_team_secret_root}"
    pivnet_token = "${var.pivnet_token}"
  }
}

resource "local_file" "prometheus_secrets" {
  content  = "${data.template_file.pivnet_secrets.rendered}"
  filename = "${var.key_dir}/pivotalcf/pivnet-secrets.yml"

  provisioner "local-exec" {
    command =<<COMMAND
eval "$(bbl print-env)"
credhub import --file ${self.filename}
COMMAND
  }
}
