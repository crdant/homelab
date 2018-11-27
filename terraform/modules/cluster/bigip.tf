resource "random_pet" "bigip_password" {
  length = 4
}

data "template_file" "partition" {
  template = "${file("${var.template_dir}/cluster/partition.json")}"
  vars {
    partition = "${var.cluster}"
  }
}

resource "restapi_object" "partition" {
  path = "/mgmt/tm/auth/partition"
  data = "${data.template_file.partition.rendered}"
}

data "template_file" "apps_partition" {
  template = "${file("${var.template_dir}/cluster/partition.json")}"
  vars {
    partition = "${var.cluster}-apps"
  }
}

resource "restapi_object" "apps_partition" {
  path = "/mgmt/tm/auth/partition"
  data = "${data.template_file.apps_partition.rendered}"
}

data "template_file" "user" {
  template = "${file("${var.template_dir}/cluster/user.json")}"
  vars {
    username = "${var.cluster}"
    partition = "${restapi_object.partition.id}"
    apps_partition = "${restapi_object.apps_partition.id}"
    password = "${random_pet.bigip_password.id}"
  }
}

resource "restapi_object" "user" {
  path = "/mgmt/tm/auth/user"
  data = "${data.template_file.user.rendered}"
}

data "template_file" "virtual_server" {
  template = "${file("${var.template_dir}/cluster/virtual_server.json")}"

  vars {
    virtual_server = "${var.cluster}"
    cluster = "${var.cluster}"
    pool = "${restapi_object.pool.id}"
    partition = "${restapi_object.partition.id}"
    cluster_bigip_ip = "${local.cluster_bigip_ip}"
    port = "${var.cluster_port}"
    snat_pool = "${restapi_object.snat_pool.id}"
    ssl_client_profile = "${restapi_object.ssl_profile.id}"
  }
}

resource "restapi_object" "virtual_server" {
  path = "/mgmt/tm/ltm/virtual"
  data = "${data.template_file.virtual_server.rendered}"

  read_path = "/mgmt/tm/ltm/virtual/~${restapi_object.partition.id}~${var.cluster}"
}

data "template_file" "pool" {
  template = "${file("${var.template_dir}/cluster/pool.json")}"

  vars {
    pool = "${var.cluster}-pool"
    partition = "${restapi_object.partition.id}"
    members = "${join(",", data.template_file.pool_member.*.rendered)}"
  }
}

resource "restapi_object" "pool" {
  path = "/mgmt/tm/ltm/pool"
  data = "${data.template_file.pool.rendered}"

  read_path = "/mgmt/tm/ltm/pool/~${restapi_object.partition.id}~${var.cluster}-pool"
}

data "template_file" "node" {
  template = "${file("${var.template_dir}/cluster/node.json")}"
  count = "${length(var.cluster_ips)}"

  vars {
    node_index = "${count.index}"
    node_name = "${var.cluster}"
    partition = "${restapi_object.partition.id}"
    ip_address = "${var.cluster_ips[count.index]}"
  }
}

resource "restapi_object" "node" {
  path = "/mgmt/tm/ltm/node"
  data = "${data.template_file.node.*.rendered[count.index]}"

  count = "${length(var.cluster_ips)}"

  read_path = "/mgmt/tm/ltm/node/~${restapi_object.partition.id}~${var.cluster}-${count.index}"
}

data "template_file" "pool_member" {
  template = "${file("${var.template_dir}/cluster/pool_member.json")}"
  count = "${length(var.cluster_ips)}"

  vars {
    pool_member = "${restapi_object.node.*.id[count.index]}"
    index = "${count.index}"
    pool = "${var.cluster}-pool"
    partition = "${restapi_object.partition.id}"
    port = "${var.cluster_port}"
  }
}

data "template_file" "snat_translation" {
  template = "${file("${var.template_dir}/cluster/snat_translation.json")}"
  vars {
    snat_translation = "${var.cluster}"
    partition = "${restapi_object.partition.id}"
    internal_ip = "${local.cluster_bigip_internal_ip}"
  }
}

resource "restapi_object" "snat_translation" {
  path = "/mgmt/tm/ltm/snat-translation"
  data = "${data.template_file.snat_translation.rendered}"

  read_path = "/mgmt/tm/ltm/snat-translation/~${restapi_object.partition.id}~${var.cluster}"
}

data "template_file" "snat_pool" {
  template = "${file("${var.template_dir}/cluster/snat_pool.json")}"
  vars {
    snat_pool = "${var.cluster}"
    snat_translation = "${restapi_object.snat_translation.id}"
    partition = "${restapi_object.partition.id}"
    internal_ip = "${local.cluster_bigip_internal_ip}"
  }
}

resource "restapi_object" "snat_pool" {
  path = "/mgmt/tm/ltm/snatpool"
  data = "${data.template_file.snat_pool.rendered}"

  read_path = "/mgmt/tm/ltm/snatpool/~${restapi_object.partition.id}~${var.cluster}"
}

data "template_file" "apps_snat_translation" {
  template = "${file("${var.template_dir}/cluster/snat_translation.json")}"
  vars {
    snat_translation = "${var.cluster}-apps"
    partition = "${restapi_object.apps_partition.id}"
    internal_ip = "${local.apps_bigip_internal_ip}"
  }
}

resource "restapi_object" "apps_snat_translation" {
  path = "/mgmt/tm/ltm/snat-translation"
  data = "${data.template_file.apps_snat_translation.rendered}"

  read_path = "/mgmt/tm/ltm/snat-translation/~${restapi_object.apps_partition.id}~${var.cluster}-apps"
}

data "template_file" "apps_snat_pool" {
  template = "${file("${var.template_dir}/cluster/snat_pool.json")}"
  vars {
    snat_pool = "${var.cluster}-apps"
    snat_translation = "${restapi_object.apps_snat_translation.id}"
    partition = "${restapi_object.apps_partition.id}"
    internal_ip = "${local.apps_bigip_internal_ip}"
  }
}

resource "restapi_object" "apps_snat_pool" {
  path = "/mgmt/tm/ltm/snatpool"
  data = "${data.template_file.apps_snat_pool.rendered}"

  read_path = "/mgmt/tm/ltm/snatpool/~${restapi_object.apps_partition.id}~${var.cluster}-apps"
}

# cluster certificate and SSL configuration

locals {
  certificate_tempfile_path = "/var/tmp/${data.terraform_remote_state.pipelines.pks_subdomain}.crt"
  private_key_tempfile_path = "/var/tmp/${data.terraform_remote_state.pipelines.pks_subdomain}.key"
}

resource "null_resource" "certificate_file" {
  provisioner "file" {
    content      = "${file("${var.key_dir}/${data.terraform_remote_state.pipelines.pks_subdomain}/cert.pem")}"
    destination  = "${local.certificate_tempfile_path}"

    connection {
      type     = "ssh"
      user     = "${var.bigip_admin_user}"
      password = "${data.terraform_remote_state.bbl.bigip_admin_password}"
      host     = "${data.terraform_remote_state.bbl.bigip_management_fqdn}"
    }
  }
}

data "template_file" "certificate" {
  template = "${file("${var.template_dir}/cluster/certificate.json")}"
  vars {
    certificate = "${var.cluster}-certificate"
    certificate_tempfile_path = "${local.certificate_tempfile_path}"
    partition = "${restapi_object.partition.id}"
  }
}

resource "restapi_object" "certificate" {
  path = "/mgmt/tm/sys/crypto/cert"
  data = "${data.template_file.certificate.rendered}"

  read_path = "/mgmt/tm/sys/crypto/cert/~${restapi_object.partition.id}~${var.cluster}-certificate"

  depends_on = [ "null_resource.certificate_file" ]
}

resource "null_resource" "private_key_file" {
  provisioner "file" {
    content      = "${file("${var.key_dir}/${data.terraform_remote_state.pipelines.pks_subdomain}/privkey.pem")}"
    destination  = "${local.private_key_tempfile_path}"

    connection {
      type     = "ssh"
      user     = "${var.bigip_admin_user}"
      password = "${data.terraform_remote_state.bbl.bigip_admin_password}"
      host     = "${data.terraform_remote_state.bbl.bigip_management_fqdn}"
    }
  }
}

data "template_file" "private_key" {
  template = "${file("${var.template_dir}/cluster/private_key.json")}"
  vars {
    private_key = "${var.cluster}-private-key"
    private_key_tempfile_path = "${local.private_key_tempfile_path}"
    partition = "${restapi_object.partition.id}"
  }
}

resource "restapi_object" "private_key" {
  path = "/mgmt/tm/sys/crypto/key"
  data = "${data.template_file.private_key.rendered}"

  read_path = "/mgmt/tm/sys/crypto/key/~${restapi_object.partition.id}~${var.cluster}-private-key"

  depends_on = [ "null_resource.private_key_file" ]
}

data "template_file" "ssl_profile" {
  template = "${file("${var.template_dir}/cluster/ssl_profile.json")}"
  vars {
    profile = "pks-cluster-${var.cluster}-ssl-profile"
    certificate = "${var.cluster}-certificate"
    private_key = "${var.cluster}-private-key"
    partition = "${restapi_object.partition.id}"
  }
}

resource "restapi_object" "ssl_profile" {
  path = "/mgmt/tm/ltm/profile/client-ssl"
  data = "${data.template_file.ssl_profile.rendered}"

  read_path = "/mgmt/tm/ltm/profile/client-ssl/~${restapi_object.partition.id}~pks-cluster-${var.cluster}-ssl-profile"

  depends_on = [ "restapi_object.certificate", "restapi_object.private_key" ]
}

# wildcard certificate and SSL configuration

locals {
  wildcard_certificate_tempfile_path = "/var/tmp/${data.terraform_remote_state.pipelines.pks_subdomain}-wildcard.crt"
  wildcard_private_key_tempfile_path = "/var/tmp/${data.terraform_remote_state.pipelines.pks_subdomain}-wildcard.key"
  common_partition = "Common"
}

resource "null_resource" "wildcard_certificate_file" {
  provisioner "file" {
    content      = "${acme_certificate.cluster_wildcard.certificate_pem}"
    destination  = "${local.wildcard_certificate_tempfile_path}"

    connection {
      type     = "ssh"
      user     = "${var.bigip_admin_user}"
      password = "${data.terraform_remote_state.bbl.bigip_admin_password}"
      host     = "${data.terraform_remote_state.bbl.bigip_management_fqdn}"
    }
  }
}

data "template_file" "wildcard_certificate" {
  template = "${file("${var.template_dir}/cluster/certificate.json")}"
  vars {
    certificate = "${var.cluster}-wildcard-certificate"
    certificate_tempfile_path = "${local.wildcard_certificate_tempfile_path}"
    partition = "${local.common_partition}"
  }
}

resource "restapi_object" "wildcard_certificate" {
  path = "/mgmt/tm/sys/crypto/cert"
  data = "${data.template_file.wildcard_certificate.rendered}"

  read_path = "/mgmt/tm/sys/crypto/cert/~${local.common_partition}~${var.cluster}-wildcard-certificate"

  depends_on = [ "null_resource.certificate_file" ]
}

resource "null_resource" "wildcard_private_key_file" {
  provisioner "file" {
    content      = "${acme_certificate.cluster_wildcard.private_key_pem}"
    destination  = "${local.wildcard_private_key_tempfile_path}"

    connection {
      type     = "ssh"
      user     = "${var.bigip_admin_user}"
      password = "${data.terraform_remote_state.bbl.bigip_admin_password}"
      host     = "${data.terraform_remote_state.bbl.bigip_management_fqdn}"
    }
  }
}

data "template_file" "wildcard_private_key" {
  template = "${file("${var.template_dir}/cluster/private_key.json")}"
  vars {
    private_key = "${var.cluster}-wildcard-private-key"
    private_key_tempfile_path = "${local.wildcard_private_key_tempfile_path}"
    partition = "${local.common_partition}"
  }
}

resource "restapi_object" "wildcard_private_key" {
  path = "/mgmt/tm/sys/crypto/key"
  data = "${data.template_file.wildcard_private_key.rendered}"

  read_path = "/mgmt/tm/sys/crypto/key/~${local.common_partition}~${var.cluster}-wildcard-private-key"

  depends_on = [ "null_resource.private_key_file" ]
}

data "template_file" "wildcard_ssl_profile" {
  template = "${file("${var.template_dir}/cluster/ssl_profile.json")}"
  vars {
    profile = "${var.cluster}-wildcard-ssl-profile"
    certificate = "${var.cluster}-wildcard-certificate"
    private_key = "${var.cluster}-wildcard-private-key"
    partition = "${local.common_partition}"
  }
}

resource "restapi_object" "wildcard_ssl_profile" {
  path = "/mgmt/tm/ltm/profile/client-ssl"
  data = "${data.template_file.wildcard_ssl_profile.rendered}"

  read_path = "/mgmt/tm/ltm/profile/client-ssl/~${local.common_partition}~${var.cluster}-wildcard-ssl-profile"

  depends_on = [ "restapi_object.certificate", "restapi_object.private_key" ]
}

# outputs

output "partition" {
  value = "${restapi_object.partition.id}"
}

output "apps_partition" {
  value = "${restapi_object.apps_partition.id}"
}

output "user" {
  value = "${restapi_object.user.id}"
}
