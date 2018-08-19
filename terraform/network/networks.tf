variable "domain" {
  type = "string"
}

variable "dns_servers" {
  type = "list"
  default = [ "1.1.1.1", "1.0.0.1" ]
}

variable "lab_cidr" {
  type = "string"
  default = "172.16.0.0/12"
}

locals {
  local_cidr        = "${cidrsubnet(cidrsubnet(var.lab_cidr,4,0),10,0)}"
  vpn_cidr          = "${cidrsubnet(cidrsubnet(var.lab_cidr,4,1),10,0)}"
  management_cidr   = "${cidrsubnet(cidrsubnet(var.lab_cidr,4,2),10,0)}"
  vmware_cidr       = "${cidrsubnet(cidrsubnet(var.lab_cidr,4,3),10,0)}"
  bootstrap_cidr    = "${cidrsubnet(cidrsubnet(var.lab_cidr,4,4),10,0)}"

  # subnets provided to PCF
  pcf_cidr          = "${cidrsubnet(cidrsubnet(var.lab_cidr,4,5),-3,1)}"
  infrastructure_cidr  = "${cidrsubnet(cidrsubnet(local.pcf_cidr,4,0),9,0)}"
  deployment_cidr      = "${cidrsubnet(cidrsubnet(local.pcf_cidr,4,1),3,1)}"
  services_cidr        = "${cidrsubnet(cidrsubnet(local.pcf_cidr,4,1),3,2)}"
  dynamic_cidr         = "${cidrsubnet(cidrsubnet(local.pcf_cidr,4,1),3,3)}"
  container_cidr       = "${cidrsubnet(cidrsubnet(local.pcf_cidr,4,1),3,4)}"

  # load balancer subnets
  balancer_external_cidr = "${cidrsubnet(cidrsubnet(var.lab_cidr,4,5),10,0)}"
  balancer_internal_cidr = "${cidrsubnet(cidrsubnet(var.lab_cidr,4,5),10,1)}"
}

output "local_cidr" {
  value = "${local.local_cidr}"
}

output "vpn_cidr" {
  value = "${local.vpn_cidr}"
}

output "management_cidr" {
  value = "${local.management_cidr}"
}

output "vmware_cidr" {
  value = "${local.vmware_cidr}"
}

output "bootstrap_cidr" {
  value = "${local.bootstrap_cidr}"
}

output "pcf_cidr" {
  value = "${local.pcf_cidr}"
}

output "infrastructure_cidr" {
  value = "${local.infrastructure_cidr}"
}

output "deployment_cidr" {
  value = "${local.deployment_cidr}"
}

output "services_cidr" {
  value = "${local.services_cidr}"
}

output "dynamic_cidr" {
  value = "${local.dynamic_cidr}"
}

output "container_cidr" {
  value = "${local.dynamic_cidr}"
}

output "balancer_internal_cidr" {
  value = "${local.balancer_internal_cidr}"
}

output "balancer_external_cidr" {
  value = "${local.balancer_external_cidr}"
}
