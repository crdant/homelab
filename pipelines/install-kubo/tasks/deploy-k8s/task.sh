#!/bin/bash

set -eu

cd kubo-odb-deployment
./bin/deploy_k8s kubo-environment ${KUBO_ENV}
