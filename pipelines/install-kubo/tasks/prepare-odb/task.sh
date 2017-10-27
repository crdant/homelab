#!/bin/bash

set -eu

# workaround braindead naming in script
cp odb-sdk/*.tgz odb-releases/on-demand-service-broker.tgz
cp kubo-service-adapter/*.tgz odb-releases/kubo-service-adapter-release.tgz
cp kubo-release/*.tgz odb-releases/kubo-release.tgz
cp stemcell/*.tgz odb-releases
