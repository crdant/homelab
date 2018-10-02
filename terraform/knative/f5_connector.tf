# resource "kubernetes_secret" "bigip_user" {
#   metadata {
#     name = "f5-bigip-${var.cluster}-ctlr-login"
#   }
#
#   data {
#     username = "${var.cluster}"
#     password = "${random_pet.bigip_password.id}"
#   }
#
#   depends_on = [ "google_dns_record_set.cluster", "restapi_object.virtual_server" ]
# }
