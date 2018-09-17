variable "vcenter_host" {
  type = "string"
}

variable "vcenter_iso_path" {
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
    vcenter_ip           = "${local.vcenter_server_ip}"
    primary_dns_server   = "${var.dns_servers[0]}"
    secondary_dns_server = "${var.dns_servers[1]}"
    cidr_bits            = "${substr(local.vmware_cidr, -2, -1)}"
    gateway_ip           = "${cidrhost(local.vmware_cidr,1)}"
    vcenter_fqdn         = "${local.vcenter_fqdn}"

    /* OS */
    vcenter_password = "${random_string.vcenter_password.result}"
    primary_ntp_server   = "${var.ntp_servers[0]}"
    secondary_ntp_server = "${var.ntp_servers[1]}"

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
    command = "${local.vcenter_installer}/vcsa-cli-installer/mac/vcsa-deploy install --no-ssl-certificate-verification --accept-eula --acknowledge-ceip ${self.filename}"
  }

  provisioner "local-exec" {
    command = "hdiutil unmount -force ${local.vcenter_installer}"
  }

  depends_on = [ "null_resource.vsan_cluster"]
}

variable "vcsa_name" {
  type = "string"
  default = "Embedded-vCenter-Server-Appliance"
}

resource "tls_private_key" "vcenter_ssh" {
  algorithm   = "RSA"
  rsa_bits    = 4096

  provisioner "local-exec" {
    command = <<COMMAND
      govc guest.mkdir -vm ${var.vcsa_name} -p /root/.ssh
      govc guest.chmod -vm ${var.vcsa_name} 0700 /root/.ssh
      govc guest.touch -vm ${var.vcsa_name} /root/.ssh/authorized_keys
      govc guest.download -vm ${var.vcsa_name} /root/.ssh/authorized_keys ${var.work_dir}/authorized_keys
      echo "${trimspace(self.public_key_openssh)}" >> ${var.work_dir}/authorized_keys
      govc guest.upload -f -vm ${var.vcsa_name} ${var.work_dir}/authorized_keys /root/.ssh/authorized_keys
      govc guest.chmod -vm ${var.vcsa_name} 0600 /root/.ssh/authorized_keys
COMMAND

    environment {
      GOVC_INSECURE = "1"
      GOVC_URL = "${local.vsphere_fqdn}"
      GOVC_USERNAME = "${var.vsphere_user}"
      GOVC_PASSWORD = "${var.vsphere_password}"
      GOVC_GUEST_LOGIN = "root:${random_string.vcenter_password.result}"
    }
  }

  depends_on = ["local_file.vcenter_config"]
}

resource "local_file" "vcenter_ssh_private_key" {
  content  = "${tls_private_key.vcenter_ssh.private_key_pem}"
  filename = "${var.key_dir}/id_vcenter_root.pem"
  provisioner "local-exec" {
    command = "chmod 600 ${self.filename}"
  }
}

resource "null_resource" "enable_remote_exec" {
  provisioner "local-exec" {
    command = <<COMMAND
govc guest.download -vm ${var.vcsa_name} /etc/ssh/sshd_config ${var.work_dir}/vsphere/sshd_config
sed -i -e "s/^AllowTcpForwarding no/AllowTcpForwarding yes/g " ${var.work_dir}/vsphere/sshd_config
govc guest.upload -f -vm ${var.vcsa_name} ${var.work_dir}/vsphere/sshd_config /etc/ssh/sshd_config
COMMAND

    environment {
      GOVC_INSECURE = "1"
      GOVC_URL = "${local.vsphere_fqdn}"
      GOVC_USERNAME = "${var.vsphere_user}"
      GOVC_PASSWORD = "${var.vsphere_password}"
      GOVC_GUEST_LOGIN = "root:${random_string.vcenter_password.result}"
    }
  }

  provisioner "local-exec" {
    command = <<COMMAND
govc guest.download -vm ${var.vcsa_name} /etc/passwd ${var.work_dir}/vsphere/etc_passwd
sed -i -e "s#^root:x:0:0:root:/root:/bin/appliancesh#root:x:0:0:root:/root:/bin/bash# " ${var.work_dir}/vsphere/etc_passwd
# govc guest.upload -f -vm ${var.vcsa_name} ${var.work_dir}/vsphere/etc_passwd /etc/passwd
COMMAND

    environment {
      GOVC_INSECURE = "1"
      GOVC_URL = "${local.vsphere_fqdn}"
      GOVC_USERNAME = "${var.vsphere_user}"
      GOVC_PASSWORD = "${var.vsphere_password}"
      GOVC_GUEST_LOGIN = "root:${random_string.vcenter_password.result}"
    }
  }

  depends_on = [ "local_file.vcenter_config" ]
}

output "vcenter_fqdn" {
  value = "${local.vcenter_fqdn}"
}

output "vcenter_ip" {
  value = "${local.vcenter_server_ip}"
}

output "vcenter_ssh_private_key" {
  value = "${local_file.vcenter_ssh_private_key.filename}"
}

output "vcenter_user" {
  value = "${local.vcenter_user}"
}

output "vcenter_password" {
  value = "${random_string.vcenter_password.result}"
}
