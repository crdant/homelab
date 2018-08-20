resource "vsphere_datacenter" "homelab" {
  name = "homelab"

  provisioner "local-exec" {
    command = "govc host.add -hostname ${local.vsphere_fqdn} -username ${data.terraform_remote_state.vsphere.vcenter_user} -password ${data.terraform_remote_state.vsphere.vcenter_password} -noverify"
    environment {
      GOVC_INSECURE   = "1"
      GOVC_URL        = "${local.vcenter_fqdn}"
      GOVC_USERNAME   = "${data.terraform_remote_state.vsphere.vcenter_user}"
      GOVC_PASSWORD   = "${data.terraform_remote_state.vsphere.vcenter_password}"
      GOVC_DATACENTER = "${self.name}"
    }
  }

  provider = "vsphere.vcenter"
}

resource "vsphere_compute_cluster" "homelab" {
  name          = "homelab"
  datacenter_id = "${vsphere_datacenter.homelab.id}"
  host_system_ids = ["${data.terraform_remote_state.vsphere.vsphere_physical_host_id}"]

  provider = "vsphere.vcenter"
}

data "vsphere_network" "vm_network" {
  name          = "VM Network"
  datacenter_id = "${vsphere_datacenter.homelab.id}"

  provider = "vsphere.vcenter"
}

resource "vsphere_resource_pool" "zone_1" {
  name = "zone1"
  parent_resource_pool_id = "${vsphere_compute_cluster.homelab.id}"

  provider = "vsphere.vcenter"
}

resource "vsphere_resource_pool" "zone_2" {
  name = "zone2"
  parent_resource_pool_id = "${vsphere_compute_cluster.homelab.id}"

  provider = "vsphere.vcenter"
}

resource "vsphere_resource_pool" "zone_3" {
  name = "zone3"
  parent_resource_pool_id = "${vsphere_compute_cluster.homelab.id}"

  provider = "vsphere.vcenter"
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
