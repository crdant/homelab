variable "infra_datastore" {
  type = "string"
}

variable "lb_template_name" {
  type = "string"
  default = "BIGIP Virtual Appliance 14.0.0.1"
}

data "template_file" "bigip_spec" {
  template        = "${file("${var.template_dir}/pave/bigip.json")}"
  vars {
    template_name = "${var.lb_template_name}"
    management_network = "${data.vsphere_network.infrastructure.name}"
    internal_network = "${data.vsphere_network.lb_internal.name}"
    external_network = "${data.vsphere_network.lb_external.name}"
  }
}

resource "local_file" "bigip_spec" {
  content  = "${data.template_file.bigip_spec.rendered}"
  filename = "${var.work_dir}/pave/bigip.spec"
}

resource "null_resource" "bigip_template" {
  provisioner "local-exec" {
    command = "govc import.ova --options ${local_file.bigip_spec.filename} ${var.work_dir}/BIGIP-14.0.0.1-0.0.2.ALL-scsi.ova"

    environment {
      GOVC_INSECURE = "1"
      GOVC_URL = "${local.vcenter_fqdn}"
      GOVC_USERNAME = "${data.terraform_remote_state.vsphere.vcenter_user}"
      GOVC_PASSWORD = "${data.terraform_remote_state.vsphere.vcenter_password}"
      GOVC_DATASTORE = "${var.infra_datastore}"
      GOVC_DATACENTER = "${data.vsphere_datacenter.homelab.name}"
    }
  }
}

data "vsphere_virtual_machine" "bigip_template" {
  name          = "${var.lb_template_name}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
  depends_on = [ "null_resource.bigip_template" ]
}

/*
govc vm.power --on --vm.ipath /home-lab/vm/${inventory_folder}/${appliance_name}

resource "vsphere_virtual_machine" "vm" {
  name             = "Home Lab BIGIP Virtual Appliance 14.0.0.1"
  resource_pool_id = "${data.vsphere_resource_pool.zone_1.id}"
  datastore_id     = "${var.infra_datastore}"

  num_cpus = 2
  memory   = 4096
  guest_id = "${data.vsphere_virtual_machine.bigip_template.guest_id}"

  scsi_type = "${data.vsphere_virtual_machine.bigip_template.scsi_type}"

  disk {
    name             = "disk0"
    size             = "${data.vsphere_virtual_machine.bigip_template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.bigip_template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.bigip_template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.bigip_template_from_ovf.id}"
  }

  vapp {
    properties {
      "guestinfo.Management"                        = "terraform-test.foobar.local"
      "guestinfo.interface.0.name"                = "ens192"
      "guestinfo.interface.0.ip.0.address"        = "10.0.0.100/24"
      "guestinfo.interface.0.route.0.gateway"     = "10.0.0.1"
      "guestinfo.interface.0.route.0.destination" = "0.0.0.0/0"
      "guestinfo.dns.server.0"                    = "10.0.0.10"
    }
  }
}

*/
