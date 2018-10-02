variable "state_dir" {
  type = "string"
}

data "terraform_remote_state" "pipelines" {
  backend = "gcs"
  config {
    bucket = "${var.statefile_bucket}"
    prefix = "pipelines"
    credentials = "${file(var.key_file)}"
  }
}

data "terraform_remote_state" "bbl" {
  backend = "local"
  config {
    path = "${var.state_dir}/vars/terraform.tfstate"
  }
}
