resource "kubernetes_secret" "bigip_user" {
  metadata {
    name = "f5-bigip-${var.cluster}-ctlr-login"
    namespace = "kube-system"
  }

  data {
    username = "${var.cluster}"
    password = "${random_pet.bigip_password.id}"
  }

  depends_on = [ "google_dns_record_set.cluster", "restapi_object.virtual_server" ]
}

# resource "kubernetes_service_account" "bigip" {
#   metadata {
#     name = "f5-bigip-ctlr-${var.cluster}-serviceaccount"
#     namespace = "kube-system"
#   }
#   secret {
#     name = "${kubernetes_secret.bigip_user.metadata.0.name}"
#   }
# }

resource "helm_repository" "f5_stable" {
    name = "f5-stable"
    url  = "https://f5networks.github.io/charts/stable"
}

resource "helm_release" "bigip_controller" {
  name = "f5-bigip-${var.cluster}-ctlr"
  repository = "${helm_repository.f5_stable.name}"
  chart = "f5-bigip-ctlr"

  set {
    name = "args.bigip_url"
    value = "${data.terraform_remote_state.bbl.bigip_management_fqdn}"
  }

  set {
    name = "args.bigip_partition"
    value = "${restapi_object.apps_partition.id}"
  }

  set {
    name = "args.vs_snat_pool_name"
    value = "${restapi_object.snat_pool.id}"
  }

  set {
    name = "bigip_login_secret"
    value = "${kubernetes_secret.bigip_user.metadata.0.name}"
  }

  depends_on = [ "null_resource.tiller_install" ]
}
