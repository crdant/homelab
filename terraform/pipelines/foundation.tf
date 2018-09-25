variable "iaas" {
  type = "string"
}

variable "pivnet_token" {
  type = "string"
}

variable "opsman_admin_username" {
  type = "string"
  default = "arceus"
}

variable "availability_zones" {
  type = "list"
  default = [ "AZ01", "AZ02", "AZ03" ]
}

variable "product_globs" {
  type = "string"
  default = "*.pivotal"
}

data "template_file" "foundation" {
  template = "${file("${var.template_dir}/pipelines/foundation.yml")}"

  vars {
    # IAAS type
    iaas_type = "${var.iaas}"

    # Ops Manager information and admin credentials
    opsman_domain = "${local.opsman_fqdn}"
  }
}

resource "local_file" "foundation" {
  content  = "${data.template_file.foundation.rendered}"
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

resource "local_file" "team_secrets" {
  content  = "${data.template_file.team_secrets.rendered}"
  filename = "${var.key_dir}/pipelines/team-secrets.yml"

  provisioner "local-exec" {
    command =<<COMMAND
eval "$(bbl print-env)"
credhub import --file ${self.filename}
COMMAND
  }
}
