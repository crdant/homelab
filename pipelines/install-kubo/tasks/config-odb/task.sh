#!/bin/bash

set -eu

director_state_path="environment-state"
director_name=$(bosh2 interpolate "${director_state_path}/director.yml" --path="/director_name")
secret_root="${director_name}/${DEPLOYMENT_NAME}"

uaa_ca=$(bosh2 int "${director_state_path}/creds.yml" --path="/uaa_ssl/ca")
credhub_ca=$(bosh2 int "${director_state_path}/creds.yml" --path="/credhub_tls/ca")
credhub_password=$(bosh2 int "${director_state_path}/creds.yml" --path="/credhub_cli_password")
director_ip=$(bosh2 int "${director_state_path}/director.yml" --path="/internal_ip")
credhub login -u credhub-cli -p ${credhub_password} -s "https://${director_ip}:8844" --ca-cert "${uaa_ca}"  --ca-cert "${credhub_ca}"

credhub set --name="${secret_root}/cf_sys_domain" --type="value" --value="${PCF_SYSTEM_DOMAIN}"
credhub set --name="${secret_root}/cf_username" --type="value" --value="${PCF_USERNAME}"
credhub set --name="${secret_root}/cf_password" --type="value" --value="${PCF_PASSWORD}"
