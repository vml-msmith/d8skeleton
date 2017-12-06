#!/bin/bash

## Help function
usage() {
  SCRIPT="ddrupal.sh"
  echo "$SCRIPT runs a drupal console command on docker drupal container."
  print_help_header "Examples"
  print_help_columns "$SCRIPT list" "show all available commands."
  print_help_header "Arguments"
  print_help_columns "command" "command to be run."
  print_global_help_options
}

## Shared functions
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/functions.sh"

## Error handling
trap 'error ${LINENO}' ERR

## Script variables
DRUPAL_CMD=$@
DOCKER_CMD='docker exec -it'
CMD="cd /var/www/docroot; ../vendor/bin/drupal $DRUPAL_CMD"

## if we are doing a pull request build, then dont use tty docker commands.
if [[ $APP_NAME == pr* ]];
then
  DOCKER_CMD='docker exec -i'
fi

print_header "DOCKER DRUPAL CONSOLE"
print_update "Namespace: ${APP_NAME}"
print_update "Drupal Console Command: ${DRUPAL_CMD}"

${DOCKER_CMD} ${APP_NAME}_main_1 bash -c "${CMD}"