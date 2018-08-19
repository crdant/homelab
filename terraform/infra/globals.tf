variable "email" {
  type = "string"
}

variable "aws_access_key" {
  type = "string"
}

variable "aws_secret_key" {
  type = "string"
}

variable "aws_region" {
  type = "string"
  default = "us-east-1"
}

variable "key_dir" {
  type = "string"
}

variable "work_dir" {
  type = "string"
}

variable "state_dir" {
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

output "aws_access_key" {
  value = "${var.aws_access_key}"
}

output "aws_secret_key" {
  value = "${var.aws_secret_key}"
}

output "aws_region" {
  value = "${var.aws_region}"
}

output "key_dir" {
  value = "${var.key_dir}"
}

output "work_dir" {
  value = "${var.work_dir}"
}

output "state_dir" {
  value = "${var.state_dir}"
}

output "template_dir" {
  value = "${var.template_dir}"
}
