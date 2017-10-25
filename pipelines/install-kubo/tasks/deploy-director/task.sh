#!/bin/bash

set -eu

# workaround braindead naming in script
cp /usr/bin/bosh2 /usr/local/bin/bosh-cli

# clone the config to the state so we can preserve the changes
git clone environment-state director-state

pushd director-state
config="$(pwd)"
popd

pushd kubo-odb-deployment/kubo-deployment
./bin/deploy_bosh ${config}
popd

pushd director-state
git config --global user.email $GIT_EMAIL
git config --global user.name $GIT_USER

git add -A
git commit -m "Updated current state after deploying director"

popd
