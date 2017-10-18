#!/bin/bash

set -eu

director_vars=director-config/director.yml
director_secrets=director-config/director-secrets.yml
bosh_creds=director-config/creds.yml
bosh_state=director-config/state.json

cd kubo-odb-deployment/kubo-deployment
./bin/deploy_bosh director-config

cp ${director_vars} director-state
cp ${director_secrets} director-state
cp ${bosh_creds} director-state
cp ${bosh_state} director-state
