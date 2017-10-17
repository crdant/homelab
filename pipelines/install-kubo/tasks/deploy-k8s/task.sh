#!/bin/bash

set -eu

cd kubo-odb-deployment
./bin/deploy_k8s environment-state ${KUBO_ENV}
