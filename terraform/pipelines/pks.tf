variable "pks_version_regex" {
  type = "string"
  default = "^1\\\\.1\\\\..*$"
}

variable "pks_syslog_host" {
  type = "string"
  default = "logs4.papertrail.com"
}

variable "pks_syslog_port" {
  type = "string"
  default = "36433"
}

resource "random_integer" "pks_singleton_zone" {
  min     = 0
  max     = 2
}

data "template_file" "pks_networks" {
  template = "${file("${var.template_dir}/pipelines/networks-with-service-network.yml")}"
  vars {
    # shared networking configuration for all tiles
    network = "${data.terraform_remote_state.pave.services_network}"
    service_network = "${data.terraform_remote_state.pave.pks_clusters_network}"

    availability_zone_1 = "${var.availability_zones[0]}"
    availability_zone_2 = "${var.availability_zones[1]}"
    availability_zone_3 = "${var.availability_zones[2]}"

    singleton_availability_zone = "${var.availability_zones[random_integer.pks_singleton_zone.result]}"
  }
}

data "template_file" "pks_properties" {
  template = "${file("${var.template_dir}/pipelines/pks/properties.yml")}"
  vars {
    pks_service_host = "api.${local.pks_subdomain}"

    # service plans
    availability_zone_1 = "${var.availability_zones[0]}"
    availability_zone_2 = "${var.availability_zones[1]}"
    availability_zone_3 = "${var.availability_zones[2]}"

    # cloud configuration
    vcenter_host = "${data.terraform_remote_state.bbl.vcenter_ip}"
    vcenter_datastore = "${data.terraform_remote_state.bbl.vcenter_ds}"        # vCenter datastore name to deploy Ops Manager in
    vcenter_datacenter = "${data.terraform_remote_state.bbl.vcenter_dc}"
    vcenter_folder = "${data.terraform_remote_state.bbl.pcf_inventory_folder}"

    # syslog
    syslog_host = "${var.pks_syslog_host}"
    syslog_port = "${var.pks_syslog_port}"

    certificate = "${replace(acme_certificate.pks_wildcard.certificate_pem, "\n", "\n      ")}"
    private_key = "${replace(acme_certificate.pks_wildcard.private_key_pem, "\n", "\n      ")}"
  }
}

data "template_file" "pks_resources" {
  template = "${file("${var.template_dir}/pipelines/pks/resources.yml")}"
  vars {
    # shared networking configuration for all tiles

  }
}

data "template_file" "pks_product_vars" {
  template = "${file("${var.template_dir}/pipelines/product.yml")}"

  vars {
    # shared networking configuration for all tiles
    slug = "pivotal-container-service"
    version_regex = "${var.pks_version_regex}"
    globs =  "${var.product_globs}"
  }
}

resource "local_file" "pks_product_vars" {
  content  = "${data.template_file.pks_product_vars.rendered}"
  filename = "${var.work_dir}/pipelines/pks/product.yml"
}

data "template_file" "pks_vars" {
  template = "${file("${var.template_dir}/pipelines/vars.yml")}"
  vars {
    # shared networking configuration for all tiles
    networks = "${replace(data.template_file.pks_networks.rendered, "\n", "\n  ")}"
    properties = "${replace(data.template_file.pks_properties.rendered, "\n", "\n  ")}"
    resources = "${replace(data.template_file.pks_resources.rendered, "\n", "\n  ")}"
    errands_to_disable = ""
  }
}

resource "local_file" "pks_vars" {
  content  = "${data.template_file.pks_vars.rendered}"
  filename = "${var.work_dir}/pipelines/pks/vars.yml"
}

data "template_file" "pks_secrets" {
  template = "${file("${var.template_dir}/pipelines/pks/secrets.yml")}"
  vars {
    pipeline_secret_root = "${local.install_pks_secret_root}"

    # vcenter account
    vcenter_username = "${data.terraform_remote_state.bbl.pcf_vcenter_user}"
    vcenter_password = "${data.terraform_remote_state.bbl.pcf_vcenter_password}"

    # these should be secrets, but can't be in the current pipeline
    # they are still stored for the future
    certificate = "${replace(acme_certificate.pks_wildcard.certificate_pem, "\n", "\n      ")}"
    private_key = "${replace(acme_certificate.pks_wildcard.private_key_pem, "\n", "\n      ")}"
  }

}

resource "local_file" "pks_secrets" {
  content  = "${data.template_file.pks_secrets.rendered}"
  filename = "${var.key_dir}/pipelines/pks/secrets.yml"

  provisioner "local-exec" {
    command =<<COMMAND
eval "$(bbl print-env)"
credhub import --file ${self.filename}
COMMAND
  }
}
