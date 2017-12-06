#!/bin/bash

## Help function
usage() {
  SCRIPT="run-docker.sh"
  echo "$SCRIPT builds and starts the docker containers for the project."

  print_help_header "Examples"
  print_help_columns "$SCRIPT" "Start docker containers."
  print_global_help_options
}

## Shared functions
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/functions.sh"

## Error handling
trap 'error ${LINENO}' ERR

## Main script
print_header "RUNNING DOCKER"
print_update "Namespace: ${APP_NAME}"

copy_docker_config

print_status "Copying Docker Files..."
## Remove Copy folder if exists.
rm -rf ${DIR}/../.docker/copy_${APP_NAME}
cp -R ${DIR}/../.docker/copy ${DIR}/../.docker/copy_${APP_NAME}
find ${DIR}/../.docker/copy_${APP_NAME} -type f | xargs sed -i.sedbak -e "s/APP_NAME/${APP_NAME}/g; s/APP_NETWORK/${APP_NETWORK}/g; s/APP_HOST/${APP_HOST}/g"
find ${DIR}/../.docker -name "*.sedbak" -type f -delete
rsync -rv ${DIR}/../.docker/copy_${APP_NAME}/ .
rm -rf ${DIR}/../.docker/copy_${APP_NAME}

## Startup the Docker servers.
print_status "Starting Docker servers..."
${DOCKER_COMPOSE} up -d --build

port_ssl=`docker port ${APP_NAME}_main_1 443`
port_ssl=${port_ssl#*:}

print_header "DOCKER STARTED"
print_update "Access the site at: https://localhost:${port_ssl}"