variable "bosh_director_role" {
  type = "string"
}

variable "pcf_vcenter_username" {
  type = "string"
  default = "pcf"
}

resource "null_resource" "pcf_vcenter_role" {

  provisioner "local-exec" {
    command = "govc permissions.set -principal ${var.pcf_vcenter_username}@${var.domain} -role '${var.bosh_director_role}'"

    environment {
      GOVC_INSECURE = "1"
      GOVC_URL = "${var.vcenter_ip}"
      GOVC_USERNAME = "${data.terraform_remote_state.pave.bbl_user}"
      GOVC_PASSWORD = "${data.terraform_remote_state.pave.bbl_password}"
    }
  }
}

resource "random_string" "pcf_vcenter_password" {
  length = 20
  min_upper = 1
  min_lower = 1
  min_numeric = 1
  min_special = 1
  override_special = "!"#$%&'()*+,-./:;<=>?@[\]^_`{|}~"
}

resource "null_resource" "pcf_vcenter_user" {
  provisioner "local-exec" {
    command = "govc sso.user.create -p '${random_string.pcf_vcenter_password.result}' ${var.pcf_vcenter_username}"

    environment {
      GOVC_INSECURE = "1"
      GOVC_URL = "${var.vcenter_ip}"
      GOVC_USERNAME = "${data.terraform_remote_state.pave.bbl_user}"
      GOVC_PASSWORD = "${data.terraform_remote_state.pave.bbl_password}"
    }
  }

}

output "pcf_vcenter_user" {
  value = "${var.pcf_vcenter_username}@${var.domain}"
}

output "pcf_vcenter_password" {
  value = "${random_string.pcf_vcenter_password.result}"
  sensitive = true
}
