#!/bin/bash

set -eu

# workaround braindead naming in script
bosh2 alias-env kubo -e $(bosh2 int environment-state/director.yml --path /internal_ip) --ca-cert <(bosh2 int environment-state/creds.yml --path /director_ssl/ca)

pushd environment-state
config="$(pwd)"
popd

export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=$(bosh int environment-state/creds.yml --path /admin_password)
export BOSH_ENVIRONMENT=kubo
export BOSH_DEPLOYMENT=${KUBO_SERVICE_NAME}

bosh2 delete-deployment
bosh2 clean-up
