#!/bin/bash

set -eu

kubo_config_path=environment-state

uaa_ca=$(bosh-cli int "${kubo_config_path}/creds.yml" --path="/uaa_ssl/ca")
credhub_ca=$(bosh-cli int "${kubo_config_path}/creds.yml" --path="/credhub_tls/ca")
credhub_password=$(bosh-cli int "${kubo_config_path}/creds.yml" --path="/credhub_cli_password")
director_ip=$(bosh-cli int "${kubo_config_path}/director.yml" --path="/internal_ip")
credhub login -u credhub-cli -p ${credhub_password} -s "https://${director_ip}:8844" --ca-cert "${uaa_ca}"  --ca-cert "${credhub_ca}"

director_name=$(bosh-cli interpolate "${kubo_config_path}/director.yml" --path="/director_name")

cf_sys_domain=${CF_SYS_DOMAIN}
cf_username=${CF_USERNAME}
cf_password=${CF_PASSWORD}

credhub set --name="${director_name}/${KUBO_SERVICE_NAME}/cf_sys_domain" --type="value" --value="${cf_sys_domain}"
credhub set --name="${director_name}/${KUBO_SERVICE_NAME}/cf_username" --type="value" --value="${cf_username}"
credhub set --name="${director_name}/${KUBO_SERVICE_NAME}/cf_password" --type="value" --value="${cf_password}"
