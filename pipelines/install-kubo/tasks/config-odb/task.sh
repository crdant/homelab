#!/bin/bash

set -eu

secret_root="${DIRECTOR_NAME}/${DEPLOYMENT_NAME}"
director_state_path="environment-state"

uaa_ca=$(bosh-cli int "${director_state_path}/creds.yml" --path="/uaa_ssl/ca")
credhub_ca=$(bosh-cli int "${director_state_path}/creds.yml" --path="/credhub_tls/ca")
credhub_password=$(bosh-cli int "${director_state_path}/creds.yml" --path="/credhub_cli_password")
director_ip=$(bosh-cli int "${director_state_path}/director.yml" --path="/internal_ip")
credhub login -u credhub-cli -p ${credhub_password} -s "https://${director_ip}:8844" --ca-cert "${uaa_ca}"  --ca-cert "${credhub_ca}"

director_name=$(bosh-cli interpolate "${kubo_config_path}/director.yml" --path="/director_name")

credhub set --name="${director_name}/${DEPLOYMENT_NAME}/cf_sys_domain" --type="value" --value="${PCF_SYSTEM_DOMAIN}"
credhub set --name="${director_name}/${DEPLOYMENT_NAME}/cf_username" --type="value" --value="${PCF_USERNAME}"
credhub set --name="${director_name}/${DEPLOYMENT_NAME}/cf_password" --type="value" --value="${PCF_PASSWORD}"
