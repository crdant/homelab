#!/bin/bash

set -eu

# workaround braindead naming in script
cp /usr/bin/bosh2 /usr/local/bin/bosh-cli

director_vars=director-config/director.yml
director_secrets=director-config/director-secrets.yml
bosh_creds=director-config/creds.yml
bosh_state=director-config/state.json

pushd director-config
config="$(pwd)"
popd

cd kubo-odb-deployment
./bin/deploy_bosh ${config}

cp ${director_vars} director-state
cp ${director_secrets} director-state
cp ${bosh_creds} director-state
cp ${bosh_state} director-state
