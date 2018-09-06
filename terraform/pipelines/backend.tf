terraform {
  backend "gcs" {
    prefix = "pipelines"
  }
}
