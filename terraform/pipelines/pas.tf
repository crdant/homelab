variable "pas_version_regex" {
  type = "string"
  default = "^2\\\\.3\\\\..*$"
}

variable "pas_syslog_host" {
  type = "string"
  default = "logs4.papertrail.com"
}

variable "pas_syslog_port" {
  type = "string"
  default = "36433"
}

variable "tcp_routing_ports" {
  type = "string"
  default = "1024-65536"
}

resource "random_integer" "pas_singleton_zone" {
  min     = 0
  max     = 2
}

data "template_file" "pas_networks" {
  template = "${file("${var.template_dir}/pipelines/networks.yml")}"
  vars {
    # shared networking configuration for all tiles
    network = "${data.terraform_remote_state.pave.services_network}"

    availability_zone_1 = "${var.availability_zones[0]}"
    availability_zone_2 = "${var.availability_zones[1]}"
    availability_zone_3 = "${var.availability_zones[2]}"

    singleton_availability_zone = "${var.availability_zones[random_integer.pas_singleton_zone.result]}"
  }
}

data "template_file" "pas_properties" {
  template = "${file("${var.template_dir}/pipelines/pas/properties.yml")}"
  vars {
    apps_domain = "${local.apps_domain}"
    system_domain = "${local.system_domain}"

    # static ips
    gorouter_ips = "${join(",", local.gorouter_ips)}"
    diego_brian_ips = "${join(",", local.brain_ips)}"
    tcp_router_ips = "${join(",", local.tcp_router_ips)}"
    pas_mysql_ips = "${join(",", local.pas_mysql_ips)}"

    # networking
    custom_ca_certificate = "${replace(file("${var.key_dir}/letsencrypt.pem"), "\n", "\n    ")}"
    tcp_routing_ports = "${var.tcp_routing_ports}"

    # syslog
    syslog_host = "${var.pas_syslog_host}"
    syslog_port = "${var.pas_syslog_port}"

    # internal MySQL
    mysql_email = "${var.email}"
    mysql_proxy_fqdn = "${local.mysql_proxy_fqdn}"

    # credhub
    credhub_encryption_key_1_name = "credhub-key-1"
    credhub_encryption_key_2_name = "credhub-key-2"
    credhub_encryption_key_3_name = "credhub-key-3"

    certificate = "${replace(acme_certificate.pas_wildcard.certificate_pem, "\n", "\n        ")}"
    private_key = "${replace(acme_certificate.pas_wildcard.private_key_pem, "\n", "\n        ")}"
  }
}

data "template_file" "pas_resources" {
  template = "${file("${var.template_dir}/pipelines/pas/resources.yml")}"
  vars {
    # shared networking configuration for all tiles

  }
}

data "template_file" "pas_product_vars" {
  template = "${file("${var.template_dir}/pipelines/product.yml")}"

  vars {
    # shared networking configuration for all tiles
    slug = "elastic-runtime"
    version_regex = "${var.pas_version_regex}"
    globs =  "${var.product_globs}"
  }
}

resource "local_file" "pas_product_vars" {
  content  = "${data.template_file.pas_product_vars.rendered}"
  filename = "${var.work_dir}/pipelines/pas/product.yml"
}

data "template_file" "pas_vars" {
  template = "${file("${var.template_dir}/pipelines/vars.yml")}"
  vars {
    # shared networking configuration for all tiles
    networks = "${replace(data.template_file.pas_networks.rendered, "\n", "\n  ")}"
    properties = "${replace(data.template_file.pas_properties.rendered, "\n", "\n  ")}"
    resources = "${replace(data.template_file.pas_resources.rendered, "\n", "\n  ")}"
    errands_to_disable = ""
  }
}

resource "local_file" "pas_vars" {
  content  = "${data.template_file.pas_vars.rendered}"
  filename = "${var.work_dir}/pipelines/pas/vars.yml"
}

resource "random_pet" "credhub_encryption_keys" {
  count = 3
  length = 6
}

data "template_file" "pas_secrets" {
  template = "${file("${var.template_dir}/pipelines/pas/secrets.yml")}"
  vars {
    pipeline_secret_root = "${local.install_pas_secret_root}"

    # credhub
    credhub_encryption_key_1 = "${random_pet.credhub_encryption_keys.0.id}"
    credhub_encryption_key_2 = "${random_pet.credhub_encryption_keys.1.id}"
    credhub_encryption_key_3 = "${random_pet.credhub_encryption_keys.2.id}"

    # these should be secrets, but can't be in the current pipeline
    # they are still stored for the future
    certificate = "${replace(acme_certificate.pas_wildcard.certificate_pem, "\n", "\n      ")}"
    private_key = "${replace(acme_certificate.pas_wildcard.private_key_pem, "\n", "\n      ")}"
  }

}

resource "local_file" "pas_secrets" {
  content  = "${data.template_file.pas_secrets.rendered}"
  filename = "${var.key_dir}/pipelines/pas/secrets.yml"

  provisioner "local-exec" {
    command =<<COMMAND
eval "$(bbl print-env)"
credhub import --file ${self.filename}
COMMAND
  }
}
