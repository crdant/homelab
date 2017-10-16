#!/bin/bash

set -eu

kubo_env=kubo-environments
kubo_env_name=${KUBO_ENV}
kubo_path="${kubo_env}/${kubo_env_name}"

cd kubo-deployment
./bin/generate_env_config "${kubo_env}" ${kubo_env_name} vsphere
