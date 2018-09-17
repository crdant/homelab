variable "infra_datastore" {
  type = "string"
}

variable "lb_template_name" {
  type = "string"
  default = "BIGIP Virtual Appliance 13.1.1-0.0.4"
}

variable "bigip_management_host" {
  type = "string"
}

locals {
  bigip_management_fqdn = "${var.bigip_management_host}.${var.domain}"
  bigip_management_alias = "balancer.${var.domain}"
}

data "vsphere_virtual_machine" "bigip_template" {
  name          = "${var.lb_template_name}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
  depends_on = [ "data.terraform_remote_state.pave.bigip_spec_file" ]
}

resource "random_pet" "bigip_admin_password" {
  length = 4
  provisioner "local-exec" {
    command = "security add-generic-password -a 'admin' -s 'bigip' -w '${self.id}' -U"
  }
}

resource "random_pet" "bigip_root_password" {
  length = 4
  provisioner "local-exec" {
    command = "security add-generic-password -a 'root' -s 'bigip' -w '${self.id}' -U"
  }
}

locals {
  bigip_machine_name = "Home Lab ${var.lb_template_name}"

  bigip_management_ip = "${cidrhost(local.infrastructure_cidr, 10)}"
  bigip_management_gateway = "${cidrhost(local.infrastructure_cidr, 2)}"

  bigip_internal_ip = "${cidrhost(local.balancer_internal_cidr, 10)}"
  bigip_internal_gateway = "${cidrhost(local.balancer_internal_cidr, 2)}"

  bigip_external_ip = "${cidrhost(local.balancer_external_cidr, 10)}"
  bigip_external_gateway = "${cidrhost(local.balancer_external_cidr, 2)}"

  bigip_ha_ip = "${cidrhost(local.infrastructure_cidr, 9)}"
  bigip_ha_gateway = "${cidrhost(local.infrastructure_cidr, 2)}"

}

resource "vsphere_virtual_machine" "bigip" {
  name             = "${local.bigip_machine_name}"
  resource_pool_id = "${data.vsphere_resource_pool.last_zone.id}"
  datastore_id     = "${var.infra_datastore}"
  folder = "${var.infrastructure_folder}"

  num_cpus = 2
  memory   = 4096
  guest_id = "${data.vsphere_virtual_machine.bigip_template.guest_id}"

  disk {
    label            = "Home Lab ${var.lb_template_name}.vmdk"
    size             = "${data.vsphere_virtual_machine.bigip_template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.bigip_template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.bigip_template.disks.0.thin_provisioned}"
  }

  network_interface {
    network_id = "${data.vsphere_network.infrastructure.id}"
  }

  network_interface {
    network_id = "${data.vsphere_network.lb_internal.id}"
  }

  network_interface {
    network_id = "${data.vsphere_network.lb_external.id}"
  }

  network_interface {
    network_id = "${data.vsphere_network.infrastructure.id}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.bigip_template.id}"

    customize {
      network_interface {
        ipv4_address = "${local.bigip_management_ip}"
        ipv4_netmask = "${substr(local.infrastructure_cidr, -2, -1)}"
      }

      network_interface {
        ipv4_address = "local.bigip_internal_ip"
        ipv4_netmask = "${substr(local.balancer_internal_cidr, -2, -1)}"
      }

      network_interface {
        ipv4_address = "local.bigip_external_ip"
        ipv4_netmask = "${substr(local.balancer_external_cidr, -2, -1)}"
      }

      network_interface {
        ipv4_address = "${local.bigip_ha_ip}"
        ipv4_netmask = "${substr(local.infrastructure_cidr, -2, -1)}"
      }
    }
  }

  vapp {
    properties {
      "user.admin.pwd" = "${random_pet.bigip_admin_password.id}"
      "user.root.pwd" = "${random_pet.bigip_admin_password.id}"
      "net.mgmt.add" = "${local.bigip_management_ip}"
      "net.mgmt.gw" = "${local.bigip_management_gateway}"
    }
  }

  provisioner "local-exec" {
    command = "govc vm.power --on --vm.ipath /${data.vsphere_datacenter.homelab.name}/vm/${var.infrastructure_folder}/${local.bigip_machine_name}"

    environment {
      GOVC_INSECURE = "1"
      GOVC_URL = "${local.vcenter_fqdn}"
      GOVC_USERNAME = "${data.terraform_remote_state.vsphere.vcenter_user}"
      GOVC_PASSWORD = "${data.terraform_remote_state.vsphere.vcenter_password}"
      GOVC_DATACENTER = "${data.vsphere_datacenter.homelab.name}"
    }
  }
}

output "bigip_management_host" {
  value = "${var.bigip_management_host}"
}

output "bigip_root_password" {
  value = "${random_pet.bigip_root_password.id}"
  sensitive = true
}

output "bigip_admin_password" {
  value = "${random_pet.bigip_admin_password.id}"
  sensitive = true
}

output "bigip_management_ip" {
  value = "{local.bigip_management_ip}"
}

output "bigip_internal_ip" {
  value = "{local.bigip_internal_ip}"
}

output "bigip_external_ip" {
  value = "{local.bigip_external_ip}"
}
