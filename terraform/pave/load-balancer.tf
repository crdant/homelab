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

  bigip_management_ip = "${cidrhost(local.infrastructure_cidr, 10)}"
  bigip_management_gateway = "${cidrhost(local.infrastructure_cidr, 2)}"

  bigip_ha_ip = "${cidrhost(local.balancer_ha_cidr, 10)}"
  bigip_ha_gateway = "${cidrhost(local.balancer_ha_cidr, 2)}"
}

data "template_file" "bigip_spec" {
  template        = "${file("${var.template_dir}/pave/bigip.json")}"
  vars {
    template_name = "${var.lb_template_name}"
    management_network = "${data.vsphere_network.infrastructure.name}"
    internal_network = "${data.vsphere_network.lb_internal.name}"
    external_network = "${data.vsphere_network.lb_external.name}"
    ha_network = "${data.vsphere_network.lb_ha.name}"
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

  provisioner "local-exec" {
    command = "govc vm.markastemplate '${var.lb_template_name}'"

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

  depends_on = [ "vsphere_compute_cluster.homelab" ]
}

output "bigip_spec_file" {
  value = "${local_file.bigip_spec.filename}"
}
