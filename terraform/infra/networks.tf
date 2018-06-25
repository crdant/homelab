variable "domain" {
  type = "string"
}

variable "dns_servers" {
  type = "list"
  default = [ "1.1.1.1", "1.0.0.1" ]
}

variable "network_cidr" {
  type = "string"
  default = "172.16.0.0/12"
}

variable "local_cidr" {
  type = "string"
  default = "172.16.0.0/26"
}

variable "vpn_cidr" {
  type = "string"
  default = "172.17.0.0/26"
}

variable "management_cidr" {
  type = "string"
  default = "172.18.0.0/26"
}

variable "vmware_cidr" {
  type = "string"
  default = "172.19.0.0/26"
}

variable "bootstrap_cidr" {
  type = "string"
  default = "172.20.0.0/26"
}

variable "pcf_cidr" {
  type = "string"
  default = "172.24.0.0/13"

}

variable "infrastructure_cidr" {
  type = "string"
  default = "172.24.0.0/26"
}

variable "balancer_internal_cidr" {
  type = "string"
  default = "172.25.0.0/26"
}

variable "balancer_external_cidr" {
  type = "string"
  default = "172.25.0.64/26"
}

variable "deployment_cidr" {
  type = "string"
  default = "172.26.0.0/22"
}

variable "services_cidr" {
  type = "string"
  default = "172.27.0.0/22"
}

variable "dynamic_cidr" {
  type = "string"
  default = "172.28.0.0/22"
}

variable "container_cidr" {
  type = "string"
  default = "172.29.0.0/22"
}
