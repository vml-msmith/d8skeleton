#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_NAME="$(${DIR}/read-yaml.sh docker.container_id)"
DOCKER_COMPOSE_YML="${DIR}/../.docker/docker-compose.yml.${APP_NAME}"
DOCKER_COMPOSE="docker-compose -f ${DOCKER_COMPOSE_YML}"

eval ${DOCKER_COMPOSE} run codeception codecept ${@}
exit $?
