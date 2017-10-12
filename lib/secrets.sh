bootstrap_root="/bootstrap"

generate_bootstrap_credential () {
  local component=${1}
  local name=${2}
  local user=${3}
  credhub set --type user --name "${bootstrap_root}/${component}/${name}" --username ${user} --password "$(generate_passphrase 4)"
}

get_bootstrap_credential () {
  local component=${1}
  local secret=${2}
  credhub get --name ${bootstrap_root}/${component}/${secret} --output-json
}

get_bootstrap_credential_username () {
  local component=${1}
  local secret=${2}
  credhub get --name ${bootstrap_root}/${component}/${secret} --output-json | jq '.value.username'
}

get_bootstrap_credential_password () {
  local component=${1}
  local secret=${2}
  credhub get --name ${bootstrap_root}/${component}/${secret} --output-json | jq '.value.password'
}

set_bootstrap_value () {
  local component=${1}
  local name=${2}
  local value=${3}
  credhub set --type password --name "${bootstrap_root}/${component}/${name}" --password "${value}"
}

get_bootstrap_value () {
  local component=${1}
  local secret=${2}
  credhub get --name ${bootstrap_root}/${component}/${secret} --output-json | jq --raw-output .value
}
