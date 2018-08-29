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

data "template_file" "bigip_spec" {
  template        = "${file("${var.template_dir}/pave/bigip.json")}"
  vars {
    template_name = "${var.lb_template_name}"
    management_network = "${data.vsphere_network.infrastructure.name}"
    internal_network = "${data.vsphere_network.lb_internal.name}"
    external_network = "${data.vsphere_network.lb_external.name}"
    ha_network = "${data.vsphere_network.infrastructure.name}"
  }
}

resource "local_file" "bigip_spec" {
  content  = "${data.template_file.bigip_spec.rendered}"
  filename = "${var.work_dir}/pave/bigip.spec"

  provisioner "local-exec" {
    command = "govc import.ova --options ${self.filename} --folder ${var.template_folder} ${var.work_dir}/BIGIP-13.1.1-0.0.4.ALL-scsi.ova"

    environment {
      GOVC_INSECURE = "1"
      GOVC_URL = "${local.vcenter_fqdn}"
      GOVC_USERNAME = "${data.terraform_remote_state.vsphere.vcenter_user}"
      GOVC_PASSWORD = "${data.terraform_remote_state.vsphere.vcenter_password}"
      GOVC_DATASTORE = "${var.infra_datastore}"
      GOVC_DATACENTER = "${data.vsphere_datacenter.homelab.name}"
      GOVC_RESOURCE_POOL = "/${data.vsphere_datacenter.homelab.name}/host/${data.vsphere_compute_cluster.homelab.name}/Resources/${element(var.resource_pools, length(var.resource_pools) - 1)}"
    }
  }
}

data "vsphere_virtual_machine" "bigip_template" {
  name          = "${var.lb_template_name}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
  depends_on = [ "local_file.bigip_spec" ]
}


/*
govc vm.power --on --vm.ipath /home-lab/vm/${inventory_folder}/${appliance_name}
*/

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
  bigip_management_ip = "${cidrhost(local.infrastructure_cidr, 10)}"
  bigip_management_gateway = "${cidrhost(local.infrastructure_cidr, 2)}"

  bigip_internal_ip = "${cidrhost(local.balancer_internal_cidr, 10)}"
  bigip_internal_gateway = "${cidrhost(local.balancer_internal_cidr, 2)}"

  bigip_external_ip = "${cidrhost(local.balancer_external_cidr, 10)}"
  bigip_external_gateway = "${cidrhost(local.balancer_external_cidr, 2)}"
}

/*
resource "vsphere_virtual_machine" "bigip" {
  name             = "Home Lab ${var.lb_template_name}"
  resource_pool_id = "${data.vsphere_resource_pool.zone_1.id}"
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
    }
  }

  vapp {
    properties {
      "user.admin.pwd" = "${random_pet.bigip_admin_password.result}"
      "user.root.pwd" = "${random_pet.bigip_admin_password.result}"
      "net.mgmt.add" = "${local.bigip_management_ip}"
      "net.mgmt.gw" = "${local.bigip_management_gateway}"
    }
  }
}

*/

output "bigip_root_password" {
  value = "${random_pet.bigip_root_password.id}"
}

output "bigip_admin_password" {
  value = "${random_pet.bigip_admin_password.id}"
}
