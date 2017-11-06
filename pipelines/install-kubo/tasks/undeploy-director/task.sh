#!/bin/bash

set -eu

# workaround braindead naming in script
cp /usr/bin/bosh2 /usr/local/bin/bosh-cli

# clone the config to the state so we can preserve the changes
git clone environment-state cleared-state

pushd cleared-state
config="$(pwd)"
popd

pushd kubo-odb-deployment/kubo-deployment
./bin/destroy_bosh ${config}
popd

pushd cleared-state
git config --global user.email $GIT_EMAIL
git config --global user.name $GIT_USER

git rm creds.yml director-secrets.yml director.yml state.json
# if the director is already undeployed, commit will return an error with nothing to commit, so
# let's make sure we have differences before trying to commit
git diff-index --quiet HEAD || git commit -m "Clear state after deleting director"
popd
