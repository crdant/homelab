#!/bin/bash

set -eu

local username=
local password=

cf login -a https://login.${SYSTEM_DOMAIN} -u ${username} -p ${password}
cf create-shared-domain ${TCP_DOMAIN} --router-group default-tcp
cf update-quota default --reserved-route-ports 1000
cf update-quota runaway --reserved-route-ports -1
