variable "vcenter_host" {
  type = "string"
}

variable "vcenter_iso_path" {
  type = "string"
}

variable "vcenter_license" {
  type = "string"
}

variable "infra_datastore" {
  type = "string"
}

variable "site_name" {
  type = "string"
  default = "HomeLab"
}

locals {
  vcenter_fqdn = "${var.vcenter_host}.${var.domain}"
  vcenter_ip = "${cidrhost(local.vmware_cidr, 20)}"
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

  provisioner "local-exec" {
    command = "security add-generic-password -a root -s '${local.vsphere_fqdn}' -w '${self.result}' -U"
  }
}

data "template_file" "vcenter_config" {
  template        = "${file("${var.template_dir}/vcenter/embedded_vCSA_on_ESXi.json")}"

  vars {
    /* esxi */
    vsphere_fqdn      = "${local.vsphere_fqdn}"
    vsphere_user      = "${var.vsphere_user}"
    vsphere_password  = "${var.vsphere_password}"
    vcenter_datastore = "${var.infra_datastore}"

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

resource "null_resource" "mount_iso" {
  provisioner "local-exec" {
    command = "hdiutil mount -mountpoint ${local.vcenter_installer} ${var.vcenter_iso_path}"
  }
}

resource "local_file" "vcenter_config" {
  content = "${data.template_file.vcenter_config.rendered}"
  filename = "${var.work_dir}/vsphere/embedded_vCSA_on_ESXi.json"

  provisioner "local-exec" {
    command = "${local.vcenter_installer}/vcsa-cli-installer/mac/vcsa-deploy install --no-ssl-certificate-verification --accept-eula --acknowledge-ceip ${self.filename}"
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

  depends_on = ["null_resource.mount_iso"]
}

resource "tls_private_key" "vcenter_ssh_key" {
  algorithm   = "RSA"
  rsa_bits    = 4096

  provisioner "remote-exec" {
    inline = [
      "shell chsh -s /bin/bash",
      "mkdir /root/.ssh",
      "chmod 700 /root/.ssh",
      "touch /root/.ssh/authorized_keys",
      "chmod 600 /root/.ssh/authorized_keys"
    ]
    connection {
      type     = "ssh"
      user     = "${var.vsphere_user}"
      password = "${var.vsphere_password}"
      host = "${local.vsphere_fqdn}"
    }
  }

  provisioner "file" {
    content     = "${self.public_key_openssh}"
    destination = "/root/.ssh/authorized_keys"
  }

  depends_on = ["local_file.vcenter_config"]
}

resource "local_file" "vcenter_private_key" {
  content  = "${tls_private_key.vcenter.private_key_pem}"
  filename = "${var.key_dir}/id_vcenter_root.pem"
}

resource "null_resource" "unmount_iso" {
  provisioner "local-exec" {
    command = "hdiutil unmount -force ${local.vcenter_installer}"
  }
  depends_on = ["local_file.vcenter_config"]
}
