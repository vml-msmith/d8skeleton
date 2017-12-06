#!/bin/bash

## Help function
usage() {
  SCRIPT="drupal-reset.sh"
  echo "$SCRIPT resets a drupal installation by clearing caches and importing features and other things."

  print_help_header "Examples"
  print_help_columns "$SCRIPT" "Run drupal reset against the default project."
  print_help_columns "$SCRIPT --project dev " "run a drush command using a namespaced docker instance."
  print_help_header "Arguments"
  print_help_columns "command" "run cache rebuild against the default project."
  print_global_help_options
}

## Shared functions
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/functions.sh"

## Error handling
trap 'error ${LINENO}' ERR

print_header "DRUPAL RESET"
print_update "Namespace: ${APP_NAME}"

ENVMOD_ENABLED=0
WATCHDOG_ENABLED=0

trap - ERR
$DIR/ddrush.sh --project ${APP_NAME} --quiet pml | grep "(envmod)" | grep "Enabled" &> /dev/null
if [[ "$?" == "0" ]]; then
  ENVMOD_ENABLED=1
fi
trap 'error ${LINENO}' ERR

if [ "${ENVMOD_ENABLED}" == "0" ]; then
  print_status "Enable ENVMOD..."
  $DIR/ddrush.sh --project ${APP_NAME} --quiet pm-enable envmod -y
fi

print_status "Switching Environment..."
$DIR/ddrush.sh --project ${APP_NAME} --quiet switch-environment dev

trap - ERR
$DIR/ddrush.sh --project ${APP_NAME} --quiet pml | grep "(dblog)" | grep "Enabled" &> /dev/null
if [[ "$?" == "0" ]]; then
  WATCHDOG_ENABLED=1
fi
trap 'error ${LINENO}' ERR

if [ "${WATCHDOG_ENABLED}" == "1" ]; then
  print_status "Clearing Watchdog Logs..."
  $DIR/ddrush.sh --project ${APP_NAME} --quiet watchdog-delete all -y
fi

print_status "Database Updates..."
$DIR/ddrush.sh --project ${APP_NAME} --quiet updatedb -y

print_status "Entity Updates..."
$DIR/ddrush.sh --project ${APP_NAME} --quiet entup -y

print_status "Importing Core Feature..."
$DIR/ddrush.sh --project ${APP_NAME} --quiet fim tn_vacation_core -y

print_status "Importing All Features..."
$DIR/ddrush.sh --project ${APP_NAME} --quiet fia -y

print_status "Rebuilding Cache..."
$DIR/ddrush.sh --project ${APP_NAME} --quiet cr