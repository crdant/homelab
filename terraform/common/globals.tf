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

output "email" {
  value = "${var.email}"
}

output "key_dir" {
  value = "${var.key_dir}"
}

output "work_dir" {
  value = "${var.work_dir}"
}

output "template_dir" {
  value = "${var.template_dir}"
}

variable "dns_ttl" {
  type = "string"
}
