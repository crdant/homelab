#!/bin/bash

set -eu

# workaround braindead naming in script
cp /usr/bin/bosh2 /usr/local/bin/bosh-cli

# clone the config to the state so we can preserve the changes
git clone environment-state director-state

director_vars=completed-config/director.yml
director_secrets=completed-config/director-secrets.yml
bosh_creds=completed-config/creds.yml
bosh_state=completed-config/state.json

pushd completed-config
config="$(pwd)"
popd

pushd kubo-odb-deployment/kubo-deployment
./bin/deploy_bosh ${config}
popd

cp ${director_vars} director-state
cp ${director_secrets} director-state
cp ${bosh_creds} director-state
cp ${bosh_state} director-state

pushd director-state
git config --global user.email $GIT_EMAIL
git config --global user.name $GIT_USER

git add -A
git commit -m "Added current state after deploying director"

popd
