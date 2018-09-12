variable "datacenter" {
  type = "string"
  default = "homelab"
}

variable "cluster" {
  type = "string"
  default = "homelab_primary"
}

variable "resource_pools" {
  type = "list"
  default = [ "zone-1", "zone-2", "zone-3" ]
}

resource "vsphere_datacenter" "homelab" {
  name = "${var.datacenter}"
}

data "vsphere_datacenter" "homelab" {
  name = "${vsphere_datacenter.homelab.name}"
}

resource "vsphere_compute_cluster" "homelab" {
  name = "${var.cluster}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"

  drs_enabled          = true
  drs_automation_level = "partiallyAutomated"

  provisioner "local-exec" {
    command = "govc cluster.change --vsan-enabled ${self.name}"

    environment {
      GOVC_INSECURE = "1"
      GOVC_URL = "${local.vcenter_fqdn}"
      GOVC_USERNAME = "${data.terraform_remote_state.vsphere.vcenter_user}"
      GOVC_PASSWORD = "${data.terraform_remote_state.vsphere.vcenter_password}"
      GOVC_DATASTORE = "${var.infra_datastore}"
      GOVC_DATACENTER = "${data.vsphere_datacenter.homelab.name}"
    }
  }

  provisioner "local-exec" {
    command = "govc cluster.add --hostname ${var.vsphere_host} --username ${var.vsphere_user} --password ${var.vsphere_password}"

    environment {
      GOVC_INSECURE = "1"
      GOVC_URL = "${local.vcenter_fqdn}"
      GOVC_USERNAME = "${data.terraform_remote_state.vsphere.vcenter_user}"
      GOVC_PASSWORD = "${data.terraform_remote_state.vsphere.vcenter_password}"
      GOVC_DATASTORE = "${var.infra_datastore}"
      GOVC_DATACENTER = "${data.vsphere_datacenter.homelab.name}"
      GOVC_CLUSTER = "${self.name}"
    }
  }

}

data "vsphere_compute_cluster" "homelab" {
  name          = "${vsphere_compute_cluster.homelab.name}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"

  depends_on = [ "vsphere_compute_cluster.homelab" ]
}

resource "vsphere_resource_pool" "zones" {
  count = "${length(var.resource_pools)}"
  name  = "${var.resource_pools[count.index]}"

  parent_resource_pool_id = "${data.vsphere_compute_cluster.homelab.resource_pool_id}"
}

data "vsphere_resource_pool" "first_zone" {
  name  = "${var.resource_pools[0]}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"

  depends_on = [ "vsphere_resource_pool.zones" ]
}

data "vsphere_resource_pool" "last_zone" {
  name  = "${var.resource_pools[length(var.resource_pools) - 1]}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"

  depends_on = [ "vsphere_resource_pool.zones" ]
}

data "vsphere_datastore" "vsan" {
  name  = "${var.infra_datastore}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
}

output "bbl_datacenter" {
  value = "${data.vsphere_datacenter.homelab.name}"
}

output "bbl_cluster" {
  value = "${data.vsphere_compute_cluster.homelab.name}"
}

output "bbl_resource_pool" {
  value = "${data.vsphere_resource_pool.first_zone.name}"
}

output "bbl_datastore" {
  value = "${data.vsphere_datastore.vsan.name}"
}

output "om_resource_pool" {
  value = "/${data.vsphere_datacenter.homelab.name}/host/${data.vsphere_compute_cluster.homelab.name}/Resources/${data.vsphere_resource_pool.last_zone.name}"
}

output "director_cluster" {
  value = "${data.vsphere_compute_cluster.homelab.name}"
}

output "director_resource_pools" {
  value = "/${data.vsphere_datacenter.homelab.name}/host/${data.vsphere_compute_cluster.homelab.name}/Resources/${vsphere_resource_pool.zones.*.name}"
}
