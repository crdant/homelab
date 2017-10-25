#!/bin/bash

set -eu

# This is probably not the best way to do this, but it feels a bit better than hard coding and/or abusing ops files
director_vars=director-config/director.yml
director_secrets=director-config/director-secrets.yml

# add routing configuration
cat <<ROUTING >> ${director_vars}
routing_mode: ${ROUTING_MODE}
kubernetes_master_host: ${KUBERNETES_MASTER_HOST}
kubernetes_master_port: ${KUBERNETES_MASTER_PORT}
routing-cf-api-url: ${PCF_API_URL}
routing-cf-client-id: ${PCF_CLIENT_ID}
routing-cf-uaa-url: ${PCF_UAA_URL}
routing-cf-app-domain-name: ${PCF_APPS_DOMAIN_NAME}
routing-cf-nats-internal-ips: ${PCF_NATS_INTERNAL_IPS}
routing-cf-nats-username: ${PCF_NATS_USERNAME}
routing-cf-nats-port: ${PCF_NATS_PORT}
ROUTING

cat <<SECRETS >> ${director_secrets}
routing-cf-nats-password: ${PCF_NATS_PASSWORD}
SECRETS

cp ${director_vars} completed-config
cp ${director_secrets} completed-config
