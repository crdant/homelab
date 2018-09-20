variable "pivnet_token" {
  type = "string"
}

variable "opsman_admin_username" {
  type = "string"
  default = "arceus"
}

data "template_file" "foundation" {
  template = "${file("${var.template_dir}/pipelines/foundation.yml")}"

  vars {
    # IAAS type
    iaas_type = "${iaas_type}"

    # Ops Manager information and admin credentials
    opsman_domain = "${local.opsman_fqdn}"

    # shared networking configuration for all tiles
    az_1_name = "${az_1_name}"
    az_2_name = "${az_2_name}"
    az_3_name = "${az_3_name}"
    services_network_name = "${services_network_name}"
    dynamic_services_network_name = "${dynamic_services_network_name}"
  }
}

resource "local_file" "foundation" {
  content  = "${data.template_file.foundation_vars.rendered}"
  filename = "${var.work_dir}/pipelines/foundation.yml"
}

resource "random_pet" "opsman_admin_password" {
  length = 4
}

data "template_file" "team_secrets" {
  template = "${file("${var.template_dir}/pipelines/team-secrets.yml")}"

  vars {
    # from the manifest
    pcf_team_secret_root = "${local.pcf_team_secret_root}"
    pivnet_token = "${var.pivnet_token}"

    opsman_admin_username = "${var.opsman_admin_username}"      # Username for Ops Manager admin account
    opsman_admin_password = "${random_pet.opsman_admin_password.id}"       # Password for Ops Manager admin account
  }
}

resource "local_file" "foundation" {
  content  = "${data.template_file.foundation_vars.rendered}"
  filename = "${var.key_dir}/pipelines/team-secrets.yml"

  provisioner "local-exec" {
    command =<<COMMAND
eval "$(bbl print-env)"
credhub import --file ${self.filename}
COMMAND
  }
}
