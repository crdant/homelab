#!/bin/bash

set -eu

username=$(om -t http://${OPSMAN_DOMAIN_OR_IP_ADDRESS} -u ${OPSMAN_USERNAME} -p ${OPSMAN_PASSWORD} credentials --product-name cf --credential-reference .uaa.admin_credentials --credential-field identity)
password=$(om -t http://${OPSMAN_DOMAIN_OR_IP_ADDRESS} -u ${OPSMAN_USERNAME} -p ${OPSMAN_PASSWORD} credentials --product-name cf --credential-reference .uaa.admin_credentials --credential-field password)

cf login -a https://login.${SYSTEM_DOMAIN} -u ${username} -p ${password}
cf create-shared-domain ${TCP_DOMAIN} --router-group default-tcp
cf update-quota default --reserved-route-ports 1000
cf update-quota runaway --reserved-route-ports -1
