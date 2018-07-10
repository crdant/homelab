variable "vsphere_user" {
  type = "string"
}

variable "vsphere_password" {
  type = "string"
}

variable "vsphere_host" {
  type = "string"
}

variable "vcenter_host" {
  type = "string"
}

variable "vcenter_iso_path" {
  type = "string"
}

variable "vcenter_license" {
  type = "string"
}

variable "vcenter_storage" {
  type = "string"
}

variable "site_name" {
  type = "string"
  default = "HomeLab"
}

locals {
  vsphere_fqdn = "${var.vsphere_host}.${var.domain}"
  vsphere_ip = "${cidrhost(local.vmware_cidr, 10)}"
  vcenter_fqdn = "${var.vcenter_host}.${var.domain}"
  vcenter_ip = "${cidrhost(local.vmware_cidr, 20)}"
  nested_esxi_ips = [
    "${cidrhost(local.vmware_cidr, 30)}",
    "${cidrhost(local.vmware_cidr, 40)}",
    "${cidrhost(local.vmware_cidr, 50)}"
  ]
}

locals {
  vcenter_installer = "${var.work_dir}/vsphere/vcsa_installer"
}

/*
  The password must be between 8 characters and 20 characters long. It must also
  contain at least one uppercase and lowercase letter, one number, and one
  character from '!"#$%&'()*+,-./:;<=>?@[\]^_`{|}~' and all characters must be
  ASCII. Space is not allowed in password.
 */
resource "random_string" "vcenter_password" {
  length = 20
  min_upper = 1
  min_lower = 1
  min_numeric = 1
  min_special = 1
  override_special = "!"#$%&'()*+,-./:;<=>?@[\]^_`{|}~"
}

data "template_file" "vcenter_config" {
  template        = "${file("${var.template_dir}/vcenter/embedded_vCSA_on_ESXi.json")}"

  vars {
    /* esxi */
    vsphere_fqdn      = "${local.vsphere_fqdn}"
    vsphere_user      = "${var.vsphere_user}"
    vsphere_password  = "${var.vsphere_password}"
    vcenter_datastore = "${var.vcenter_storage}"

    /* network */
    vcenter_ip           = "${local.vcenter_ip}"
    primary_dns_server   = "${var.dns_servers[0]}"
    secondary_dns_server = "${var.dns_servers[1]}"
    cidr_bits            = "${substr(local.vmware_cidr, -2, -1)}"
    gateway_ip           = "${cidrhost(local.vmware_cidr,1)}"
    vcenter_fqdn         = "${local.vcenter_fqdn}"

    /* OS */
    vcenter_password = "${random_string.vcenter_password.result}"

    /* SSO */
    domain    = "${var.domain}"
    site_name = "${var.site_name}"
  }

}

locals {
  vcenter_user = "administrator@${var.domain}"
}

resource "local_file" "vcenter_config" {
  content = "${data.template_file.vcenter_config.rendered}"
  filename = "${var.work_dir}/vsphere/embedded_vCSA_on_ESXi.json"

  provisioner "local-exec" {
    command = "hdiutil mount -mountpoint ${local.vcenter_installer} ${var.vcenter_iso_path}"
  }

  provisioner "local-exec" {
    command = "${local.vcenter_installer}/vcsa-cli-installer/mac/vcsa-deploy install --no-esx-ssl-verify --accept-eula --acknowledge-ceip ${self.filename}"
  }

  provisioner "local-exec" {
    command = "hdiutil unmount ${local.vcenter_installer}"
  }

  provisioner "local-exec" {
    command = "govc license.add ${var.vcenter_license}"
    environment {
      GOVC_INSECURE = "1"
      GOVC_URL = "${local.vcenter_fqdn}"
      GOVC_USERNAME = "${local.vcenter_user}"
      GOVC_PASSWORD = "${random_string.vcenter_password.result}"
    }
  }
}
