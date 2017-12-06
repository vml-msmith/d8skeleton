#!/bin/bash

## Help function
usage() {
  SCRIPT="dcomposer.sh"
  echo "$SCRIPT runs composer in the docker container."

  print_help_header "Examples"
  print_help_columns "$SCRIPT install --prefer-dist" "Runs a local composer install."
  print_help_columns "$SCRIPT install --prefer-dist --no-dev -o --verbose" "Runs production composer install."

  print_global_help_options
  print_help_header "Options"
  print_help_columns "--jenkins" "Runs composer as jenkins user."
}

## Shared functions
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/functions.sh"

## Error handling
trap 'error ${LINENO}' ERR

## Script default variables
JENKINS=0

## Script options
while [ "$1" != "" ]; do
  case $1 in
    --jenkins )
      JENKINS=1
      ;;
    * )
      break
  esac
  shift
done

## Script variables
CONTAINER=${APP_NAME}_composer
COMPOSER_CMD=$@

print_header "DOCKER COMPOSER"
print_update "Namespace: ${APP_NAME}"
print_update "Command: ${COMPOSER_CMD}"

print_status "Building docker container..."
docker build -f .docker/Dockerfile.composer -t ${CONTAINER} .docker

print_status "Starting docker container..."

if [ $JENKINS == 1 ]; then
  docker run --network=host --user=jenkins --name ${CONTAINER} --rm -v ${DIR}/../docroot:/app ${CONTAINER} ${COMPOSER_CMD}
else
  docker run --network=host --name ${CONTAINER} --rm -v ${DIR}/../docroot:/app ${CONTAINER} ${COMPOSER_CMD}
fi

docker_cleanup ${CONTAINER}
