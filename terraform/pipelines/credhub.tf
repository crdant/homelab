variable "credhub_version_regex" {
  type = "string"
  default = "^1\\\\.0\\\\..*$"
}

resource "random_integer" "credhub_singleton_zone" {
  min     = 0
  max     = 2
}

data "template_file" "credhub_networks" {
  template = "${file("${var.template_dir}/pipelines/networks-with-service-network.yml")}"
  vars {
    # shared networking configuration for all tiles
    network = "${data.terraform_remote_state.pave.services_network}"
    service_network = "${data.terraform_remote_state.pave.services_network}"

    availability_zone_1 = "${var.availability_zones[0]}"
    availability_zone_2 = "${var.availability_zones[1]}"
    availability_zone_3 = "${var.availability_zones[2]}"

    singleton_availability_zone = "${var.availability_zones[random_integer.credhub_singleton_zone.result]}"
  }
}

data "template_file" "credhub_properties" {
  template = "${file("${var.template_dir}/pipelines/credhub/properties.yml")}"
  vars {
    org = "tools"
    space = "secrets"
  }
}

data "template_file" "credhub_resources" {
  template = "${file("${var.template_dir}/pipelines/credhub/resources.yml")}"
  vars {

  }
}


data "template_file" "credhub_product_vars" {
  template = "${file("${var.template_dir}/pipelines/product.yml")}"
  vars {
    # shared networking configuration for all tiles
    name = "credhub-service-broker"
    slug = "credhub-service-broker"
    version_regex = "${var.credhub_version_regex}"
    globs = "${var.product_globs}"
  }
}

resource "local_file" "credhub_product_vars" {
  content  = "${data.template_file.credhub_product_vars.rendered}"
  filename = "${var.work_dir}/pipelines/credhub/product.yml"
}

data "template_file" "credhub_vars" {
  template = "${file("${var.template_dir}/pipelines/vars.yml")}"
  vars {
    networks = "${replace(data.template_file.credhub_networks.rendered, "\n", "\n  ")}"
    properties = "${replace(data.template_file.credhub_properties.rendered, "\n", "\n  ")}"
    resources = "${replace(data.template_file.credhub_resources.rendered, "\n", "\n  ")}"
    errands_to_disable = ""
  }
}

resource "local_file" "credhub_install_vars" {
  content  = "${data.template_file.credhub_vars.rendered}"
  filename = "${var.work_dir}/pipelines/credhub/vars.yml"
}
