#!/bin/bash

set -eu

cd kubo-deployment
./bin/deploy_bosh kubo-environment
