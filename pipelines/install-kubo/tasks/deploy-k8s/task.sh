#!/bin/bash

set -eu

# workaround braindead naming in script
cp /usr/bin/bosh2 /usr/local/bin/bosh-cli
bosh-cli alias-env environment-state -e $(bosh-cli int environment-state/director.yml --path /internal_ip) --ca-cert <(bosh-cli int environment-state/creds.yml --path /director_ssl/ca)

pushd environment-state
config="$(pwd)"
popd
set -x
cd kubo-odb-deployment/kubo-deployment
./bin/deploy_k8s ${config} ${KUBO_ENV} public
set +x
