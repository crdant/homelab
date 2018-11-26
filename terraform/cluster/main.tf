module "cluster" {
  source = "../modules/cluster"

  cluster               = "${var.cluster}"
  cluster_index         = "${var.cluster_index}"
  cluster_ips           = "${var.cluster_ips}"

  work_dir              = "${var.work_dir}"
  key_dir               = "${var.key_dir}"
  key_file              = "${var.key_file}"
  template_dir          = "${var.template_dir}"
  state_dir             = "${var.state_dir}"
  statefile_bucket      = "${var.statefile_bucket}"

  project               = "${var.project}"
  email                 = "${var.email}"

  domain                = "${var.domain}"
  dns_ttl               = "${var.dns_ttl}"
}
