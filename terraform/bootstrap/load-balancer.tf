variable "infra_datastore" {
  type = "string"
}

variable "lb_template_name" {
  type = "string"
  default = "bigip-appliance-13.1.1-0.0.4"
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
  bigip_machine_name = "${var.env_id}-${var.lb_template_name}"

  bigip_management_ip = "${cidrhost(local.infrastructure_cidr, 10)}"
  bigip_management_gateway = "${cidrhost(local.infrastructure_cidr, 2)}"

  bigip_internal_ip = "${cidrhost(local.balancer_internal_cidr, 10)}"
  bigip_internal_gateway = "${cidrhost(local.balancer_internal_cidr, 2)}"

  bigip_external_ip = "${cidrhost(local.balancer_external_cidr, 10)}"
  bigip_external_gateway = "${cidrhost(local.balancer_external_cidr, 2)}"

  bigip_ha_ip = "${cidrhost(local.balancer_ha_cidr, 10)}"
  bigip_ha_gateway = "${cidrhost(local.balancer_ha_cidr, 2)}"
}

data "vsphere_network" "lb_external" {
  name          = "${data.terraform_remote_state.pave.lb_external_network}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

data "vsphere_network" "lb_internal" {
  name          = "${data.terraform_remote_state.pave.lb_internal_network}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

data "vsphere_network" "lb_ha" {
  name          = "${data.terraform_remote_state.pave.lb_ha_network}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

data "vsphere_network" "infrastructure" {
  name          = "${data.terraform_remote_state.pave.infrastructure_network}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

data "vsphere_resource_pool" "last_resource_pool" {
  name = "${element(data.terraform_remote_state.pave.director_resource_pool_names,length(data.terraform_remote_state.pave.director_resource_pool_names) - 1)}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

data "vsphere_datastore" "infrastructure_datastore" {
  name = "${var.infra_datastore}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

# resource "vsphere_virtual_machine" "bigip" {
#   name             = "${local.bigip_machine_name}"
#   resource_pool_id = "${data.vsphere_resource_pool.last_resource_pool.id}"
#   datastore_id     = "${data.vsphere_datastore.infrastructure_datastore.id}"
#
#   folder = "${data.terraform_remote_state.pave.infrastructure_folder}"
#
#   num_cpus = 2
#   memory   = 4096
#   guest_id = "${data.vsphere_virtual_machine.bigip_template.guest_id}"
#
#   disk {
#     label            = "Home Lab ${var.lb_template_name}.vmdk"
#     size             = "${data.vsphere_virtual_machine.bigip_template.disks.0.size}"
#     eagerly_scrub    = "${data.vsphere_virtual_machine.bigip_template.disks.0.eagerly_scrub}"
#     thin_provisioned = "${data.vsphere_virtual_machine.bigip_template.disks.0.thin_provisioned}"
#   }
#
#   network_interface {
#     network_id = "${data.vsphere_network.infrastructure.id}"
#   }
#
#   network_interface {
#     network_id = "${data.vsphere_network.lb_internal.id}"
#   }
#
#   network_interface {
#     network_id = "${data.vsphere_network.lb_external.id}"
#   }
#
#   network_interface {
#     network_id = "${data.vsphere_network.infrastructure.id}"
#   }
#
#   clone {
#     template_uuid = "${data.vsphere_virtual_machine.bigip_template.id}"
#
#     customize {
#       linux_options {
#         host_name = "${var.bigip_management_host}"
#         domain    = "${var.domain}"
#       }
#
#       network_interface {
#         ipv4_address = "${local.bigip_management_ip}"
#         ipv4_netmask = "${substr(local.infrastructure_cidr, -2, -1)}"
#       }
#
#       network_interface {
#         ipv4_address = "${local.bigip_internal_ip}"
#         ipv4_netmask = "${substr(local.balancer_internal_cidr, -2, -1)}"
#       }
#
#       network_interface {
#         ipv4_address = "${local.bigip_external_ip}"
#         ipv4_netmask = "${substr(local.balancer_external_cidr, -2, -1)}"
#       }
#
#       network_interface {
#         ipv4_address = "${local.bigip_ha_ip}"
#         ipv4_netmask = "${substr(local.infrastructure_cidr, -2, -1)}"
#       }
#     }
#   }
#
#   provisioner "local-exec" {
#     command = "govc vm.power --on --vm.ipath /${data.vsphere_datacenter.homelab.name}/vm/${data.terraform_remote_state.pave.infrastructure_folder}/${local.bigip_machine_name}"
#
#     environment {
#       GOVC_INSECURE = "1"
#       GOVC_URL = "${var.vcenter_ip}"
#       GOVC_USERNAME = "${var.vcenter_user}"
#       GOVC_PASSWORD = "${var.vcenter_password}"
#       GOVC_DATACENTER = "${data.vsphere_datacenter.homelab.name}"
#     }
#   }
# }

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
  value = "${local.bigip_management_ip}"
}

output "bigip_internal_ip" {
  value = "${local.bigip_internal_ip}"
}

output "bigip_external_ip" {
  value = "${local.bigip_external_ip}"
}
