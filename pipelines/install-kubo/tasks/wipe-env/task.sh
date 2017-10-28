#!/bin/bash

set -eu

# workaround braindead naming in script
bosh-cli alias-env kubo -e $(bosh-cli int environment-state/director.yml --path /internal_ip) --ca-cert <(bosh-cli int environment-state/creds.yml --path /director_ssl/ca)

pushd environment-state
config="$(pwd)"
popd

export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=$(bosh int environment-state/creds.yml --path /admin_password)
export BOSH_ENVIRONMENT=kubo
export BOSH_DEPLOYMENT=${KUBO_SERVICE_NAME}

bosh delete-deployment
bosh clean-up
