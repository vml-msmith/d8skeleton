#!/bin/bash

## Help function
usage() {
  SCRIPT="kill-docker.sh"
  echo "$SCRIPT stops and destroys the docker containers for the project."

  print_help_header "Examples"
  print_help_columns "$SCRIPT" "Kill docker containers."
  print_global_help_options
}

## Shared functions
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/functions.sh"

## Error handling
trap 'error ${LINENO}' ERR

## Main script
print_header "KILLING DOCKER"
print_update "Namespace: ${APP_NAME}"

copy_docker_config

## Startup the Docker servers. Ensures a new build first.
print_status "Stopping docker servers..."
${DOCKER_COMPOSE} down --remove-orphans

print_status "Cleaning up..."
trap - ERR
docker system prune -f
exit 0