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
