variable "minio_host" {
  type = "string"
  default = "storage"
}

locals {
  minio_fqdn = "${var.minio_host}.pcf.${var.domain}"
}

variable "minio_version_regex" {
  type = "string"
  default = "^1\\\\.0\\\\..*$"
}

variable "minio_plan_vm_type" {
  type = "string"
  default = "nano"
}

variable "minio_plan_disk" {
  type = "string"
  default = "2048"
}

variable "minio_plan_vms" {
  type = "string"
  default = "1"
}

resource "random_integer" "minio_singleton_zone" {
  min     = 0
  max     = 2
}

data "template_file" "minio_networks" {
  template = "${file("${var.template_dir}/pipelines/minio/networks.yml")}"
  vars {
    # shared networking configuration for all tiles
    network = "${data.terraform_remote_state.pave.services_network}"

    availability_zone_1 = "${var.availability_zones[0]}"
    availability_zone_2 = "${var.availability_zones[1]}"
    availability_zone_3 = "${var.availability_zones[2]}"

    singleton_availability_zone = "${var.availability_zones[random_integer.minio_singleton_zone.result]}"
  }
}

data "template_file" "minio_properties" {
  template = "${file("${var.template_dir}/pipelines/minio/properties.yml")}"
  vars {
    org = "minio"
    space = "storage"

    # for the service plan
    vm_type = "${var.minio_plan_vm_type}"
    disk_type = "${var.minio_plan_disk}"
    number_of_vms = "${var.minio_plan_vms}"

    availability_zone_1 = "${var.availability_zones[0]}"
    availability_zone_2 = "${var.availability_zones[1]}"
    availability_zone_3 = "${var.availability_zones[2]}"
  }
}

data "template_file" "minio_resources" {
  template = "${file("${var.template_dir}/pipelines/minio/resources.yml")}"
  vars {

  }
}


data "template_file" "minio_product_vars" {
  template = "${file("${var.template_dir}/pipelines/product.yml")}"
  vars {
    # shared networking configuration for all tiles
    slug = "minio"
    version_regex = "${var.minio_version_regex}"
    globs = "${var.product_globs}"
  }
}

resource "local_file" "minio_product_vars" {
  content  = "${data.template_file.minio_product_vars.rendered}"
  filename = "${var.work_dir}/pipelines/minio/product.yml"
}

data "template_file" "minio_vars" {
  template = "${file("${var.template_dir}/pipelines/vars.yml")}"
  vars {
    networks = "${replace(data.template_file.minio_networks.rendered, "\n", "\n  ")}"
    properties = "${replace(data.template_file.minio_properties.rendered, "\n", "\n  ")}"
    resources = "${replace(data.template_file.minio_resources.rendered, "\n", "\n  ")}"
    errands_to_disable = ""
  }
}

resource "local_file" "minio_install_vars" {
  content  = "${data.template_file.minio_vars.rendered}"
  filename = "${var.work_dir}/pipelines/minio/vars.yml"
}
