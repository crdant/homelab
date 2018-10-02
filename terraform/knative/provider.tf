variable "bigip_admin_user" {
  type = "string"
  default = "admin"
}

provider "kubernetes" {
  config_context_cluster   = "${var.cluster}"
}

provider "helm" {
  kubernetes {
    config_context = "${var.cluster}"
  }
}

provider "restapi" {
  uri      = "https://${data.terraform_remote_state.bbl.bigip_management_fqdn}"
  username = "${var.bigip_admin_user}"
  password = "${data.terraform_remote_state.bbl.bigip_admin_password}"
  id_attribute = "name"

  write_returns_object = true
}
