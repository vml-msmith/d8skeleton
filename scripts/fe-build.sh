#!/bin/bash

## Help function
usage() {
  SCRIPT="fe-build.sh"
  echo "$SCRIPT runs front-end build processes in the docker container."

  print_help_header "Examples"
  print_help_columns "$SCRIPT" "Runs all applicable processes against all themes."
  print_help_columns "$SCRIPT -theme=admin --process=gulp-watch" "Runs gulp watch on the admin theme."

  print_global_help_options
  print_help_header "Options"
  print_help_columns "--theme" "Run processes on a single defined theme. Required for watch commands."
  print_help_columns "--process" "Specify which process to run. Can be defined multiple times."
  print_help_columns "" "Themes and available processes are defined in the environment.yml file."

  print_help_header "Processes"
  print_help_columns "npm" "Runs npm install."
  print_help_columns "npm-rebuild" "Remove node_modules and then npm install."
  print_help_columns "bower" "Runs bower install."
  print_help_columns "gulp-build" "Runs gulp build."
  print_help_columns "gulp-build-dev" "Runs gulp build--dev."
  print_help_columns "gulp-watch" "Runs gulp watch."
}

## Shared functions
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/functions.sh"

## Error handling
trap 'error ${LINENO}' ERR

## Script variables
CONTAINER=${APP_NAME}_fe_builder
BUILD_CMD=$@
export UID

## Main script
print_header "FRONT END BUILDER"
print_update "Namespace: ${APP_NAME}"

print_status "Building docker container..."
docker build -f .docker/Dockerfile.fe_builder -t ${CONTAINER} .docker

print_status "Starting docker container..."
docker run -t  --network=host --user=${UID} --name ${CONTAINER} --rm -v ${DIR}/..:/var/www ${CONTAINER} ${BUILD_CMD}

docker_cleanup ${CONTAINER}
