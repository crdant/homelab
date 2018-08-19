init () {
  component=${1}
  pushd "${terraform_dir}/${component}"
    terraform init \
      --backend-config=<(backend_config)
  popd
}

apply () {
  component=${1}
  pushd "${terraform_dir}/${component}"
    terraform apply \
      --auto-approve \
      --var-file=<(terraform_vars) \
  popd
}

backend_config () {
  cat <<CONFIG
credentials = <<CREDENTIALS
  $(cat ${key_file})
CREDENTIALS
region = "${region}"
bucket = "${statefile_bucket}"
CONFIG
}
