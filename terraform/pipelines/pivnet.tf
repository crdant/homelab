variable "pivnet_token" {
  type = "string"
}

data "template_file" "pivnet_secrets" {
  template = "${file("${var.template_dir}/pipelines/pivnet-secrets.yml")}"
  vars {
    # from the manifest
    pcf_team_secret_root = "${local.pcf_team_secret_root}"
    pivnet_token = "${var.pivnet_token}"
  }
}

resource "local_file" "pivnet_secrets" {
  content  = "${data.template_file.pivnet_secrets.rendered}"
  filename = "${var.key_dir}/pipelines/pivnet-secrets.yml"

  provisioner "local-exec" {
    command =<<COMMAND
eval "$(bbl print-env)"
credhub import --file ${self.filename}
COMMAND
  }
}
