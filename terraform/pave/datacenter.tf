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

/*
export BBL_VSPHERE_VCENTER_USER
export BBL_VSPHERE_VCENTER_PASSWORD
export BBL_VSPHERE_VCENTER_IP
export BBL_VSPHERE_VCENTER_DC
export BBL_VSPHERE_VCENTER_CLUSTER
export BBL_VSPHERE_VCENTER_RP
export BBL_VSPHERE_NETWORK
export BBL_VSPHERE_VCENTER_DS
export BBL_VSPHERE_SUBNET
*/
