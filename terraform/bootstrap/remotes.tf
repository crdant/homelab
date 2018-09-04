data "terraform_remote_state" "pave" {
  backend = "gcs"
  config {
    bucket = "${var.statefile_bucket}"
    prefix = "pave"
    credentials = "${file(var.key_file)}"
  }
}
