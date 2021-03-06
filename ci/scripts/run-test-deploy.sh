#!/usr/bin/env bash

####################################### GLOBAL VARS ###########################################

## Parameters
POOL_DIR="$( cd "$1" && pwd )"
REPO_DIR="$( cd "$2" && pwd )"
LOG_DIR="$( cd "$3" && pwd )"
TILE_DIR="$( cd "$4" && pwd )"


TILE_FILE=`cd "${TILE_DIR}"; ls *.pivotal`
if [ -z "${TILE_FILE}" ]; then
   echo "No files matching ${TILE_DIR}/*.pivotal"
   ls -lR "${TILE_DIR}"
   exit 1
fi

PRODUCT=`echo "${TILE_FILE}" | sed "s/-[^-]*$//"`
VERSION=`echo "${TILE_FILE}" | sed "s/.*-//" | sed "s/\.pivotal\$//"`

echo "PRODUCT: $PRODUCT"
echo "VERSION: $VERSION"

## Commands
PCF=pcf

####################################### FUNCTIONS ###########################################

function log() {
	echo ""
	echo `date` $1
}

function which_pcf() {
  PIE_NAME=`cat ${POOL_DIR}/name`
  log "${POOL_DIR}/pcf/claimed/${PIE_NAME}:"
  cat ${POOL_DIR}/pcf/claimed/$PIE_NAME
}

####################################### MAIN ###########################################

cd ${POOL_DIR}

which_pcf
set -ex

APP_DOMAIN=`$PCF cf-info | grep apps_domain | cut -d" " -f3`

$PCF target -o forgerock-broker-org -s forgerock-broker-space
cf delete-org -f forgerock-broker-tests
cf create-org forgerock-broker-tests
cf target -o forgerock-broker-tests
cf create-space test
cf target -s test

${REPO_DIR}/ci/scripts/tests.py ${REPO_DIR} ${APP_DOMAIN}
