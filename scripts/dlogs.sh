#!/bin/bash

## Help function
usage() {
  SCRIPT="dlogs.sh"
  echo "$SCRIPT tails the docker http and php error logs."
  print_global_help_options
}

## Shared functions
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/functions.sh"

## Error handling
trap 'error ${LINENO}' ERR

## Script variables
DOCKER_CMD='docker exec -it'

## if we are doing a pull request build, then dont use tty docker commands.
if [[ $APP_NAME == pr* ]];
then
  DOCKER_CMD='docker exec -i'
fi

CMD="tail -f /var/log/httpd/ssl_error_log /var/log/httpd/error_log"

${DOCKER_CMD} ${APP_NAME}_main_1 bash -c "${CMD}"