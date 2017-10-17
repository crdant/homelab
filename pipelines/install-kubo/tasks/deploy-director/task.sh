#!/bin/bash

set -eu

cd kubo-odb-deployment/kubo-deployment
./bin/deploy_bosh kubo-environment
