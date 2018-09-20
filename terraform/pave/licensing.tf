variable "vsphere_license" {
  type = "string"
}

variable "vcenter_license" {
  type = "string"
}

resource "vsphere_license" "vcenter_license" {
  license_key = "${var.vcenter_license}"

  provisioner "local-exec" {
    command = "govc license.assign ${var.vcenter_license}"
    environment {
      GOVC_INSECURE = "1"
      GOVC_URL = "${local.vcenter_fqdn}"
      GOVC_USERNAME = "${data.terraform_remote_state.vsphere.vcenter_user}"
      GOVC_PASSWORD = "${data.terraform_remote_state.vsphere.vcenter_password}"
    }
  }
}


resource "vsphere_license" "vsphere_license" {
  license_key = "${var.vsphere_license}"
}
