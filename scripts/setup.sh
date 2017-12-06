#!/bin/bash

## Help function
usage() {
  SCRIPT="setup.sh"
  echo "$SCRIPT initializes the project and runs everything needed for first time setup."

  print_help_header "Examples"
  print_help_columns "$SCRIPT" "Set up local environment."
  print_help_header "Arguments"
  print_help_columns "environment" "Environment to sync. (dev|stage|prod)"
  print_global_help_options
}

## Shared functions
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/functions.sh"

## Error handling
trap 'error ${LINENO}' ERR

## Script variables
ENVIRONMENT=$1
ALIAS="$(${DIR}/read-yaml.sh drush.aliases.$ENVIRONMENT)"

if [ -z $ALIAS ]; then
  print_error "No drush alias found for $ENVIRONMENT"
  exit 1
fi

## Main script
print_header "PROJECT SETUP"
print_update "Namespace: ${APP_NAME}"

$DIR/run-docker.sh --project ${APP_NAME}
$DIR/dcomposer.sh --project ${APP_NAME} install --prefer-dist -v -o
$DIR/envsync.sh --no-confirm --no-composer ${ENVIRONMENT}
$DIR/fe-build.sh

port_ssl=`docker port ${APP_NAME}_main_1 443`
port_ssl=${port_ssl#*:}

print_header "PROJECT READY"
print_update "Access the site at: https://localhost:${port_ssl}"