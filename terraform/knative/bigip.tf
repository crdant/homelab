resource "random_pet" "bigip_password" {
  length = 4
}

data "template_file" "partition" {
  template = "${file("${var.template_dir}/cluster/partition.json")}"
  vars {
    partition_name = "${var.cluster}"
  }
}

resource "restapi_object" "partition" {
  path = "/mgmt/tm/auth/partition"
  data = "${data.template_file.partition.rendered}"
}

data "template_file" "user" {
  template = "${file("${var.template_dir}/cluster/user.json")}"
  vars {
    username = "${var.cluster}"
    partition = "${restapi_object.partition.id}"
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

output "partition" {
  value = "${restapi_object.partition.id}"
}

output "user" {
  value = "${restapi_object.user.id}"
}
