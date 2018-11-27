variable "cluster" {
  type = "string"
}

variable "cluster_index" {
  type = "string"
  default = "41"
}

variable "cluster_port" {
  type = "string"
  default = "8443"
}

locals {
  cluster_bigip_ip = "${cidrhost(local.balancer_external_cidr,var.cluster_index)}"
  cluster_bigip_internal_ip = "${cidrhost(local.balancer_internal_cidr,var.cluster_index)}"
  apps_bigip_internal_ip = "${cidrhost(local.balancer_internal_cidr,var.cluster_index + 1)}"
  cluster_fqdn = "${var.cluster}.${data.terraform_remote_state.pipelines.pks_subdomain}"
}
