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
