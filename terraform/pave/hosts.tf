variable "vsphere_user" {
  type = "string"
}

variable "vsphere_password" {
  type = "string"
}

variable "vsphere_host" {
  type = "string"
}

locals {
  vsphere_fqdn = "${var.vsphere_host}.${var.domain}"
}

resource "null_resource" "homelab_host" {
  provisioner "local-exec" {
    command = "govc host.add --hostname ${local.vsphere_fqdn} --username ${var.vsphere_user} --password ${var.vsphere_password} --noverify"

    environment {
      GOVC_INSECURE = "1"
      GOVC_URL = "${local.vcenter_fqdn}"
      GOVC_USERNAME = "${data.terraform_remote_state.vsphere.vcenter_user}"
      GOVC_PASSWORD = "${data.terraform_remote_state.vsphere.vcenter_password}"
      GOVC_DATACENTER = "${data.vsphere_datacenter.homelab.name}"
    }
  }

  depends_on = [ "vsphere_folder.hosts" ]
}

resource "null_resource" "autostart" {
  provisioner "local-exec" {
    command = "govc host.autostart.configure --enabled --host ${local.vsphere_fqdn}"

    environment {
      GOVC_INSECURE = "1"
      GOVC_URL = "${local.vcenter_fqdn}"
      GOVC_USERNAME = "${data.terraform_remote_state.vsphere.vcenter_user}"
      GOVC_PASSWORD = "${data.terraform_remote_state.vsphere.vcenter_password}"
    }
  }
}

/*
resource "null_resource" "vsan_nic" {
  provisioner "local-exec" {
    command = "govc host.vnic.service --host ${local.vsphere_fqdn} --enable vsan vmk7"

    environment {
      GOVC_INSECURE = "1"
      GOVC_URL = "${local.vcenter_fqdn}"
      GOVC_USERNAME = "${data.terraform_remote_state.vsphere.vcenter_user}"
      GOVC_PASSWORD = "${data.terraform_remote_state.vsphere.vcenter_password}"
    }
  }
}
*/

data "vsphere_host" "homelab" {
  name = "${local.vsphere_fqdn}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
  depends_on = [ "null_resource.homelab_host" ]
}

output "vsphere_host" {
  value = "${data.vsphere_host.homelab.name}"
}
