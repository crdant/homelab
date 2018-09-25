variable "registry_host" {
  type = "string"
  default = "registry"
}

variable "harbor_version_regex" {
  type = "string"
  default = "^1\\\\.5\\\\..*$"
}

variable "harbor_auth_mode" {
  type = "string"
  default = "uaa_auth_pks"
}

variable "registry_storage_type" {
  type = "string"
  default = "filesystem"
}

variable "harbor_access_key" {
  type = "string"
  default = "harbor"
}

variable "with_clair" {
  type = "string"
  default = "true"
}

variable "with_notary" {
  type = "string"
  default = "true"
}

locals {
  registry_fqdn = "${var.registry_host}.pcf.${var.domain}"
}

resource "random_integer" "harbor_singleton_zone" {
  min     = 0
  max     = 2
}

data "template_file" "harbor_networks" {
  template = "${file("${var.template_dir}/pipelines/networks.yml")}"
  vars {
    # shared networking configuration for all tiles
    network = "${data.terraform_remote_state.pave.services_network}"

    availability_zone_1 = "${var.availability_zones[0]}"
    availability_zone_2 = "${var.availability_zones[1]}"
    availability_zone_3 = "${var.availability_zones[2]}"

    singleton_availability_zone = "${var.availability_zones[random_integer.harbor_singleton_zone.result]}"
  }
}

data "template_file" "harbor_properties" {
  template = "${file("${var.template_dir}/pipelines/harbor/properties.yml")}"
  vars {
    # value: ${secret_key}
    auth_mode = "${var.harbor_auth_mode}"
    registry_fqdn = "${local.registry_fqdn}"
    storage_type = "${var.registry_storage_type}"
    with_clair = "${var.with_clair}"
    with_notary = "${var.with_notary}"
    # these should be secrets, but can't be in the current pipeline
    certificate = "${replace(acme_certificate.registry.certificate_pem, "\n", "\n      ")}"
    private_key = "${replace(acme_certificate.registry.private_key_pem, "\n", "\n      ")}"
  }
}

data "template_file" "harbor_resources" {
  template = "${file("${var.template_dir}/pipelines/harbor/resources.yml")}"
  vars {
    # shared networking configuration for all tiles

  }
}

data "template_file" "harbor_product_vars" {
  template = "${file("${var.template_dir}/pipelines/product.yml")}"

  vars {
    # shared networking configuration for all tiles
    slug = "harbor-container-registry"
    version_regex = "${var.harbor_version_regex}"
    globs =  "${var.product_globs}"
  }
}

resource "local_file" "harbor_product_vars" {
  content  = "${data.template_file.harbor_product_vars.rendered}"
  filename = "${var.work_dir}/pipelines/harbor/product.yml"
}

data "template_file" "harbor_vars" {
  template = "${file("${var.template_dir}/pipelines/vars.yml")}"
  vars {
    # shared networking configuration for all tiles
    networks = "${replace(data.template_file.harbor_networks.rendered, "\n", "\n  ")}"
    properties = "${replace(data.template_file.harbor_properties.rendered, "\n", "\n  ")}"
    resources = "${replace(data.template_file.harbor_resources.rendered, "\n", "\n  ")}"
    errands_to_disable = ""
  }
}

resource "local_file" "harbor_vars" {
  content  = "${data.template_file.harbor_vars.rendered}"
  filename = "${var.work_dir}/pipelines/harbor/vars.yml"
}

resource "random_pet" "harbor_admin_password" {
  length = 4
}

data "template_file" "harbor_secrets" {
  template = "${file("${var.template_dir}/pipelines/harbor/secrets.yml")}"
  vars {
    pipeline_secret_root = "${local.install_harbor_secret_root}"
    admin_password = "${random_pet.harbor_admin_password.id}"
    # these should be secrets, but can't be in the current pipeline
    # they are still stored for the future
    certificate = "${replace(acme_certificate.registry.certificate_pem, "\n", "\n      ")}"
    private_key = "${replace(acme_certificate.registry.private_key_pem, "\n", "\n      ")}"
  }

}

resource "local_file" "harbor_secrets" {
  content  = "${data.template_file.harbor_secrets.rendered}"
  filename = "${var.key_dir}/pipelines/harbor/secrets.yml"

  provisioner "local-exec" {
    command =<<COMMAND
eval "$(bbl print-env)"
credhub import --file ${self.filename}
COMMAND
  }
}
