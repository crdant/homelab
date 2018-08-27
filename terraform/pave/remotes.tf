data "terraform_remote_state" "vsphere" {
  backend = "gcs"
  config {
    bucket = "${var.statefile_bucket}"
    prefix = "vsphere"
    credentials = "${file(var.key_file)}"
  }
}
