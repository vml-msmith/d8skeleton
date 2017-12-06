#!/bin/bash

## Help function
usage() {
  SCRIPT="stop-docker.sh"
  echo "$SCRIPT stops the docker containers for the project."

  print_help_header "Examples"
  print_help_columns "$SCRIPT" "Stop docker containers."
  print_global_help_options
}

## Shared functions
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/functions.sh"

## Error handling
trap 'error ${LINENO}' ERR

## Main script
print_header "STOPPING DOCKER"
print_update "Namespace: ${APP_NAME}"

copy_docker_config

## Startup the Docker servers. Ensures a new build first.
print_status "Stopping Docker containers..."
${DOCKER_COMPOSE} stop

print_header "DOCKER STOPPED"