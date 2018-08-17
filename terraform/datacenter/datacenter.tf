provider vsphere {
  alias          = "vcenter"
  user           = "${local.vcenter_user}"
  password       = "${random_string.vcenter_password.result}"
  vsphere_server = "${local.vcenter_fqdn}"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

resource "vsphere_datacenter" "homelab" {
  name = "homelab"

  provisioner "local-exec" {
    command = "govc host.add -hostname ${local.vsphere_fqdn} -username ${var.vsphere_user} -password ${var.vsphere_password} -noverify"
    environment {
      GOVC_INSECURE   = "1"
      GOVC_URL        = "${local.vcenter_fqdn}"
      GOVC_USERNAME   = "${local.vcenter_user}"
      GOVC_PASSWORD   = "${random_string.vcenter_password.result}"
      GOVC_DATACENTER = "${self.name}"
    }
  }
}

resource "vsphere_compute_cluster" "homelab" {
  name          = "homelab"
  datacenter_id = "${vsphere_datacenter.homelab.id}"
  host_system_ids = ["${data.vsphere_host.physical.id}"]
}

data "vsphere_network" "vm_network" {
  name          = "VM Network"
  datacenter_id = "${vsphere_datacenter.homelab.id}"
}

resource "vsphere_resource_pool" "zone_1" {
  name = "zone1"
  parent_resource_pool_id = "${vsphere_compute_cluster.homelab.id}"
}

resource "vsphere_resource_pool" "zone_2" {
  name = "zone2"
  parent_resource_pool_id = "${vsphere_compute_cluster.homelab.id}"
}

resource "vsphere_resource_pool" "zone_3" {
  name = "zone3"
  parent_resource_pool_id = "${vsphere_compute_cluster.homelab.id}"
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
