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

provider "google" {
  credentials = "${file("${var.key_file}")}"
  project     = "${var.project}"
  region      = "${var.region}"
}

output "project" {
  value = "${var.project}"
}

output "key_file" {
  value = "${var.key_file}"
}

output "location" {
  value = "${var.region}"
}

output "statefile_bucket" {
  value = "${var.statefile_bucket}"
}
