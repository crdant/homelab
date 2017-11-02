#!/bin/bash

set -eu

echo "Configuring TCP routing..."
username=$(om -t http://${OPSMAN_DOMAIN_OR_IP_ADDRESS} -u ${OPSMAN_USERNAME} -p ${OPSMAN_PASSWORD} credentials --product-name cf --credential-reference .uaa.admin_credentials --credential-field identity)
password=$(om -t http://${OPSMAN_DOMAIN_OR_IP_ADDRESS} -u ${OPSMAN_USERNAME} -p ${OPSMAN_PASSWORD} credentials --product-name cf --credential-reference .uaa.admin_credentials --credential-field password)

cf login -a https://login.${SYSTEM_DOMAIN} -u ${username} -p ${password}

echo "Creating domain for TCP routing..."
cf create-shared-domain ${TCP_DOMAIN} --router-group default-tcp

echo "Updating standard quotas to allow TCP routes..."
cf update-quota default --reserved-route-ports 1000
cf update-quota runaway --reserved-route-ports -1
