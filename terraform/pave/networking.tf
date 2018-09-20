variable "vsan_switch" {
  type = "string"
  default = "vSwitch0"
}

variable "vsan_port" {
  type = "string"
  default = "255"
}

locals {
  vsan_vmk = "vmk${var.vsan_port}"
  vsan_ip = "${cidrhost(local.vmware_cidr,34)}"
  vsan_gateway = "${cidrhost(local.vmware_cidr,1)}"
  vsan_netmask = "${cidrnetmask(local.vmware_cidr)}"
}

variable "vsan_portgroup" {
  type = "string"
  default = "vSAN Network"
}

variable "bootstrap_switch" {
  type = "string"
  default = "bootstrap_switch"
}

variable "bootstrap_port" {
  type = "string"
  default = "2"
}

locals {
  bootstrap_nic = "vmnic${var.bootstrap_port}"
  bootstrap_ip = "${cidrhost(local.bootstrap_cidr,2)}"
  bootstrap_gateway = "${cidrhost(local.bootstrap_cidr,1)}"
  bootstrap_netmask = "${cidrnetmask(local.bootstrap_cidr)}"
}

variable "bootstrap_portgroup" {
  type = "string"
  default = "bootstrap"
}

variable "pcf_switch" {
  type = "string"
  default = "pcf_switch"
}

variable "pcf_port" {
  type = "string"
  default = "3"
}

locals {
  pcf_nic = "vmnic${var.pcf_port}"

  infrastructure_ip = "${cidrhost(local.infrastructure_cidr,2)}"
  lb_internal_ip = "${cidrhost(local.balancer_internal_cidr,2)}"
  lb_external_ip = "${cidrhost(local.balancer_external_cidr,2)}"
  lb_ha_ip = "${cidrhost(local.balancer_ha_cidr,2)}"
  deployment_ip = "${cidrhost(local.deployment_cidr,2)}"
  services_ip = "${cidrhost(local.services_cidr,2)}"
  pks_clusters_ip = "${cidrhost(local.container_cidr,2)}"
}

variable "infrastructure_portgroup" {
  type = "string"
  default = "infrastructure"
}

variable "deployment_portgroup" {
  type = "string"
  default = "deployment"
}

variable "services_portgroup" {
  type = "string"
  default = "services"
}

variable "pks_portgroup" {
  type = "string"
  default = "pks_clusters"
}

variable "load_balancer_internal_portgroup" {
  type = "string"
  default = "bigip_internal"
}

variable "load_balancer_external_portgroup" {
  type = "string"
  default = "bigip_external"
}

variable "load_balancer_ha_portgroup" {
  type = "string"
  default = "bigip_ha"
}

resource "vsphere_host_port_group" "vsan" {
  name = "${var.vsan_portgroup}"
  host_system_id = "${data.vsphere_host.homelab.id}"

  virtual_switch_name = "${var.vsan_switch}"

  provisioner "local-exec" {
    command = <<COMMANDS
govc host.esxcli network ip interface add --interface-name '${local.vsan_vmk}' --portgroup-name '${self.name}'
govc host.esxcli network ip interface ipv4 set --interface-name ${local.vsan_vmk} --ipv4 ${local.vsan_ip} --netmask ${local.vsan_netmask} --gateway ${local.vsan_gateway} --type static
govc host.esxcli network ip interface tag add --interface-name ${local.vsan_vmk} -t VSAN
COMMANDS

    environment {
      GOVC_INSECURE = "1"
      GOVC_URL = "${local.vsphere_fqdn}"
      GOVC_USERNAME = "${var.vsphere_user}"
      GOVC_PASSWORD = "${var.vsphere_password}"
    }
  }

}


locals {
  nic_add_script = [ "yes", "|", "pwsh -Command \"",
    "Set-PowerCLIConfiguration -InvalidCertificateAction 'Ignore'  -Scope 'Session' ;",
    "Connect-VIServer -Server ${local.vcenter_fqdn} -Protocol https -User '${data.terraform_remote_state.vsphere.vcenter_user}' -Password '${data.terraform_remote_state.vsphere.vcenter_password}' ;",
    "\\$$homelabHost = Get-VMHost -Name ${local.vsphere_fqdn} ;",
    "\\$$pcfSwitch = Get-VDSwitch -VMHost \\$$homelabHost -Name $SWITCH ;",
    "New-VMHostNetworkAdapter -VMHost \\$$homelabHost -VirtualSwitch \\$$pcfSwitch -PortGroup $PORTGROUP -IP $IP -SubnetMask $NETMASK",
    "\""
  ]
}

resource "vsphere_distributed_virtual_switch" "bootstrap" {
  name          = "${var.bootstrap_switch}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"

  uplinks         = [ "${var.bootstrap_switch}" ]
  active_uplinks  = [ "${var.bootstrap_switch}" ]

  host {
    host_system_id = "${data.vsphere_host.homelab.id}"
    devices        = [ "${local.bootstrap_nic}" ]
  }

}

data "vsphere_distributed_virtual_switch" "bootstrap" {
  name          = "${vsphere_distributed_virtual_switch.bootstrap.name}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
  depends_on    = [ "vsphere_distributed_virtual_switch.bootstrap" ]
}

resource "vsphere_distributed_port_group" "bootstrap" {
  name                            = "${var.bootstrap_portgroup}"
  distributed_virtual_switch_uuid = "${data.vsphere_distributed_virtual_switch.bootstrap.id}"

  provisioner "local-exec" {
    command = "${join(" ", local.nic_add_script)}"
    environment {
      SWITCH    = "${data.vsphere_distributed_virtual_switch.bootstrap.name}"
      PORTGROUP = "${self.name}"
      IP = "${local.bootstrap_ip}"
      NETMASK = "${local.bootstrap_netmask}"
    }
  }
}

data "vsphere_network" "bootstrap" {
  name          = "${vsphere_distributed_port_group.bootstrap.name}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
  depends_on    = [ "vsphere_distributed_port_group.bootstrap" ]
}

resource "vsphere_distributed_virtual_switch" "pcf" {
  name          = "${var.pcf_switch}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"

  uplinks         = [ "${var.pcf_switch}" ]
  active_uplinks  = [ "${var.pcf_switch}" ]

  host {
    host_system_id = "${data.vsphere_host.homelab.id}"
    devices        = [ "${local.pcf_nic}" ]
  }
}

data "vsphere_distributed_virtual_switch" "pcf" {
  name          = "${vsphere_distributed_virtual_switch.pcf.name}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
  depends_on    = [ "vsphere_distributed_virtual_switch.pcf" ]
}

resource "vsphere_distributed_port_group" "lb_internal" {
  name                            = "${var.load_balancer_internal_portgroup}"
  distributed_virtual_switch_uuid = "${data.vsphere_distributed_virtual_switch.pcf.id}"

  provisioner "local-exec" {
    command = "${join(" ", local.nic_add_script)}"
    environment {
      SWITCH    = "${data.vsphere_distributed_virtual_switch.pcf.name}"
      PORTGROUP = "${self.name}"
      IP = "${local.lb_internal_ip}"
      NETMASK = "${local.lb_internal_netmask}"
    }
  }
}

data "vsphere_network" "lb_internal" {
  name          = "${vsphere_distributed_port_group.lb_internal.name}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
  depends_on    = [ "vsphere_distributed_port_group.lb_internal" ]
}

resource "vsphere_distributed_port_group" "lb_external" {
  name                            = "${var.load_balancer_external_portgroup}"
  distributed_virtual_switch_uuid = "${data.vsphere_distributed_virtual_switch.pcf.id}"

  provisioner "local-exec" {
    command = "${join(" ", local.nic_add_script)}"
    environment {
      SWITCH    = "${data.vsphere_distributed_virtual_switch.pcf.name}"
      PORTGROUP = "${self.name}"
      IP = "${local.lb_external_ip}"
      NETMASK = "${local.lb_external_netmask}"
    }
  }
}

data "vsphere_network" "lb_external" {
  name          = "${vsphere_distributed_port_group.lb_external.name}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
  depends_on    = [ "vsphere_distributed_port_group.lb_external" ]
}

resource "vsphere_distributed_port_group" "lb_ha" {
  name                            = "${var.load_balancer_ha_portgroup}"
  distributed_virtual_switch_uuid = "${data.vsphere_distributed_virtual_switch.pcf.id}"

  provisioner "local-exec" {
    command = "${join(" ", local.nic_add_script)}"
    environment {
      SWITCH    = "${data.vsphere_distributed_virtual_switch.pcf.name}"
      PORTGROUP = "${self.name}"
      IP = "${local.lb_ha_ip}"
      NETMASK = "${local.lb_ha_netmask}"
    }
  }
}

data "vsphere_network" "lb_ha" {
  name          = "${vsphere_distributed_port_group.lb_ha.name}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
  depends_on    = [ "vsphere_distributed_port_group.lb_ha" ]
}

resource "vsphere_distributed_port_group" "infrastructure" {
  name                            = "${var.infrastructure_portgroup}"
  distributed_virtual_switch_uuid = "${data.vsphere_distributed_virtual_switch.pcf.id}"

  provisioner "local-exec" {
    command = "${join(" ", local.nic_add_script)}"
    environment {
      SWITCH    = "${data.vsphere_distributed_virtual_switch.pcf.name}"
      PORTGROUP = "${self.name}"
      IP = "${local.infrastructure_ip}"
      NETMASK = "${local.infrastructure_netmask}"
    }
  }
}

data "vsphere_network" "infrastructure" {
  name          = "${vsphere_distributed_port_group.infrastructure.name}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
  depends_on    = [ "vsphere_distributed_port_group.infrastructure" ]
}

resource "vsphere_distributed_port_group" "deployment" {
  name                            = "${var.deployment_portgroup}"
  distributed_virtual_switch_uuid = "${data.vsphere_distributed_virtual_switch.pcf.id}"

  provisioner "local-exec" {
    command = "${join(" ", local.nic_add_script)}"
    environment {
      SWITCH    = "${data.vsphere_distributed_virtual_switch.pcf.name}"
      PORTGROUP = "${self.name}"
      IP = "${local.deployment_ip}"
      NETMASK = "${local.deployment_netmask}"
    }
  }
}

data "vsphere_network" "deployment" {
  name          = "${vsphere_distributed_port_group.deployment.name}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
  depends_on    = [ "vsphere_distributed_port_group.deployment" ]
}

resource "vsphere_distributed_port_group" "services" {
  name                            = "${var.services_portgroup}"
  distributed_virtual_switch_uuid = "${data.vsphere_distributed_virtual_switch.pcf.id}"

  provisioner "local-exec" {
    command = "${join(" ", local.nic_add_script)}"
    environment {
      SWITCH    = "${data.vsphere_distributed_virtual_switch.pcf.name}"
      PORTGROUP = "${self.name}"
      IP = "${local.services_ip}"
      NETMASK = "${local.services_netmask}"
    }
  }
}

data "vsphere_network" "services" {
  name          = "${vsphere_distributed_port_group.services.name}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
  depends_on    = [ "vsphere_distributed_port_group.services" ]
}

resource "vsphere_distributed_port_group" "pks_clusters" {
  name                            = "${var.pks_portgroup}"
  distributed_virtual_switch_uuid = "${data.vsphere_distributed_virtual_switch.pcf.id}"

  provisioner "local-exec" {
    command = "${join(" ", local.nic_add_script)}"
    environment {
      SWITCH    = "${data.vsphere_distributed_virtual_switch.pcf.name}"
      PORTGROUP = "${self.name}"
      IP = "${local.pks_clusters_ip}"
      NETMASK = "${local.pks_clusters_netmask}"
    }
  }
}

data "vsphere_network" "pks_clusters" {
  name          = "${vsphere_distributed_port_group.pks_clusters.name}"
  datacenter_id = "${data.vsphere_datacenter.homelab.id}"
  depends_on    = [ "vsphere_distributed_port_group.pks_clusters" ]
}

output "bootstrap_network" {
  value = "${data.vsphere_network.bootstrap.name}"
}

output "lb_internal_network" {
  value = "${data.vsphere_network.lb_internal.name}"
}

output "lb_external_network" {
  value = "${data.vsphere_network.lb_external.name}"
}

output "lb_ha_network" {
  value = "${data.vsphere_network.lb_ha.name}"
}

output "infrastructure_network" {
  value = "${data.vsphere_network.infrastructure.name}"
}

output "deployment_network" {
  value = "${data.vsphere_network.deployment.name}"
}

output "services_network" {
  value = "${data.vsphere_network.services.name}"
}

output "pks_clusters_network" {
  value = "${data.vsphere_network.pks_clusters.name}"
}
