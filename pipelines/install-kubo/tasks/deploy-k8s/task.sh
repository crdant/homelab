#!/bin/bash

set -eu

pushd environment-state
config="$(pwd)"
popd
set -x
cd kubo-odb-deployment/kubo-deployment
./bin/deploy_k8s ${config} ${KUBO_ENV}
set +x
