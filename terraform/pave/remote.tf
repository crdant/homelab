data "terraform_remote_state" "infra" {
  backend "gcs" {
    prefix = "infra"
  }
}
