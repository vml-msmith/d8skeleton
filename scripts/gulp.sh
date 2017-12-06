#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_NAME="$(${DIR}/read-yaml.sh docker.container_id)"
DOCKER_COMPOSE_YML="${DIR}/../.docker/docker-compose.yml.${APP_NAME}"
DOCKER_COMPOSE="docker-compose  -f ${DOCKER_COMPOSE_YML}"

echo ${DOCKER_COMPOSE} run gulper ${@}
export UID
docker build -f .docker/Dockerfile.gulper -t tngulp .docker

if docker ps -a | grep gulper_run; then
  CLEANUP=`docker rm -f $(docker ps -a | grep gulper_run | cut -d" " -f1)`
fi

## echo docker run -t --user=${UID} --name gulper_run --rm -v ${DIR}/..:/var/www tngulp $@
docker run -t --user=${UID} --name gulper_run --rm -v ${DIR}/..:/var/www tngulp $@

EXIT_CODE=$?
if docker ps -a | grep gulper_run; then
	CLEANUP=`docker rm -f $(docker ps -a | grep gulper_run | cut -d" " -f1)`
fi
exit $EXIT_CODE