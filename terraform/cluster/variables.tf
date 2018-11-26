variable "cluster" {
  type = "string"
}

variable "cluster_index" {
  type = "string"
  default = "41"
}

variable "cluster_port" {
  type = "string"
  default = "8443"
}

variable "project" {
  type = "string"
}

variable "key_file" {
  type = "string"
}

variable "region" {
  type = "string"
  default = "us-east-1"
}

variable "statefile_bucket" {
  type = "string"
}

variable "cluster_ips" {
  type = "list"
}

variable "email" {
  type = "string"
}

variable "key_dir" {
  type = "string"
}

variable "work_dir" {
  type = "string"
}

variable "template_dir" {
  type = "string"
}

variable "ntp_servers" {
  type = "list"
  default = [ "0.pool.ntp.org", "1.pool.ntp.org", "2.pool.ntp.org", "3.pool.ntp.org" ]
}

variable "dns_ttl" {
  type = "string"
}

variable "tiller_service_account" {
  type = "string"
  default = "tiller"
}

variable "domain" {
  type = "string"
}

variable "dns_servers" {
  type = "list"
  default = [ "1.1.1.1", "1.0.0.1", "8.8.8.8" ]
}

variable "lab_cidr" {
  type = "string"
  default = "172.16.0.0/12"
}

variable "bigip_admin_user" {
  type = "string"
  default = "admin"
}

variable "state_dir" {
  type = "string"
}
