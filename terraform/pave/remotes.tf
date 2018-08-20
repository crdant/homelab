data "terraform_remote_state" "vsphere" {
  backend "gcs" {
    prefix = "vsphere"
  }
}
