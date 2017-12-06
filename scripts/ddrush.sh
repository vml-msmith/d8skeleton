#!/bin/bash

## Help function
usage() {
  SCRIPT="ddrush.sh"
  echo "$SCRIPT runs a drush command on docker drupal container."
  print_help_header "Examples"
  print_help_columns "$SCRIPT cr" "run cache rebuild against the default project."
  print_help_columns "$SCRIPT --project dev cr" "run a drush command using a namespaced docker instance."
  print_help_header "Arguments"
  print_help_columns "command" "run cache rebuild against the default project."
  print_global_help_options
}

## Shared functions
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/functions.sh"

## Error handling
trap 'error ${LINENO}' ERR

## Script variables
DRUSH_CMD=$@
DOCKER_CMD='docker exec -it'
CMD="cd /var/www/docroot; ../vendor/bin/drush $DRUSH_CMD"

## if we are doing a pull request build, then dont use tty docker commands.
if [[ $APP_NAME == pr* ]];
then
  DOCKER_CMD='docker exec -i'
fi

print_header "DOCKER DRUSH"
print_update "Namespace: ${APP_NAME}"
print_update "Drush Command: ${DRUSH_CMD}"

${DOCKER_CMD} docker_${APP_NAME}_1 bash -c "${CMD}"
