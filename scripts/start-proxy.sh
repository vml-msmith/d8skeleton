#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

docker ps -a | awk '{ print $1,$2 }' | grep nginx | awk '{print $1 }' | xargs -I {} docker rm {}
docker-compose -f ${DIR}/../.docker/docker-compose.yml.nginx up -d
