
init () {
  component=${1}
  pushd "${terraform_dir}/${component}" > /dev/null
    terraform init \
      --backend-config=<(backend_config)
  popd > /dev/null
}

apply () {
  component=${1}
  pushd "${terraform_dir}/${component}" > /dev/null
    terraform apply \
      --input=false \
      --auto-approve \
      --var-file=<(terraform_vars)
  popd > /dev/null
}

target () {
  component=${1}
  resource=${2}
  pushd "${terraform_dir}/${component}" > /dev/null
    terraform apply \
      --input=false \
      --auto-approve \
      --var-file=<(terraform_vars) \
      --target "${terraform_dir}/${component}"
  popd > /dev/null
}

destroy () {
  component=${1}
  pushd "${terraform_dir}/${component}" > /dev/null
    terraform destroy \
      --input=false \
      --auto-approve \
      --var-file=<(terraform_vars)
  popd > /dev/null
}

outputs () {
  component=${1}
  pushd "${terraform_dir}/${component}" > /dev/null
    terraform output --json
  popd > /dev/null
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
