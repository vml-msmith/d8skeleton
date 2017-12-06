#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_NAME="$(${DIR}/read-yaml.sh docker.container_id)"
DOCKER_COMPOSE_YML="${DIR}/../.docker/docker-compose.yml.${APP_NAME}"
DOCKER_COMPOSE="docker-compose -f ${DOCKER_COMPOSE_YML}"

eval ${DOCKER_COMPOSE} run phpunit /var/www/docroot/core/scripts/run-tests.sh --sqlite tmp/test.sqlite --verbose --non-html --color --php /usr/bin/php --concurrency 15 ${@}
exit $?
