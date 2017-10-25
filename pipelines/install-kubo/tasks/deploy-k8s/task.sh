#!/bin/bash

set -eu

# workaround braindead naming in script
cp /usr/bin/bosh2 /usr/local/bin/bosh-cli

pushd environment-state
config="$(pwd)"
popd
set -x
cd kubo-odb-deployment/kubo-deployment
./bin/deploy_k8s ${config} ${KUBO_ENV}
set +x
