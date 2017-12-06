#!/bin/bash

error() {
  local parent_lineno="$1"
  local message="$2"
  local code="${3:-1}"
  local me=`basename "$0"`
  
  ## Clean up abandoned spinners
  if [[ -n "$_sp_pid" ]] ; then
    stop_spinner
  fi

  if [[ -n "$message" ]] ; then
    print_error "Error in ${me} on or near line ${parent_lineno}: ${message}; exiting with status ${code}"
  else
    print_error "Error in ${me} on or near line ${parent_lineno}; exiting with status ${code}"
  fi
  exit "${code}"
}

print_header() {
  if [ $QUIET == 0 ]; then
    printf "${BLUE}===== ${1} ======${NC}\n"
  fi
}

print_status() {
  if [ $QUIET == 0 ]; then
    printf "${YELLOW}${1}${NC}\n"
  fi
}

print_update() {
  if [ $QUIET == 0 ]; then
    printf "${GREEN}${1}${NC}\n"
  fi
}

print_error() {
  if [ $QUIET == 0 ]; then
    printf "${RED}${1}${NC}\n"
  fi
}

print_help_header() {
  echo ""
  echo "$1:"
}

print_help_columns() {
  printf "%-50s %s\n" " $1" "$2"
}

print_global_help_options() {
  print_help_header "Global Options"
  print_help_columns "--help" "Display this help message."
  print_help_columns "--project" "Override the default project namespace."
  print_help_columns "--quiet" "Supress extra output."
  print_help_columns "--no-colors" "Do not use terminal colors in output."
}

copy_docker_config() {
  ## Make sure the docker-compose.yml has the correct settings.
  print_status "Copying Docker Configuration..."
  cp ${DIR}/../.docker/docker-compose.yml.default ${DOCKER_COMPOSE_YML}
  sed -i.sedbak -e "s/APP_NAME/${APP_NAME}/g; s/APP_NETWORK/${APP_NETWORK}/g; s/APP_HOST/${APP_HOST}/g" ${DOCKER_COMPOSE_YML}
}

docker_cleanup() {
  print_status "Cleaning up..."
  
  if docker ps -a | grep ${1}; then
    CLEANUP=`docker rm $(docker ps -a | grep ${1} | cut -d" " -f1)`
  fi
}

## Color Definitions
RED='\033[38;5;160m'
GREEN='\033[38;5;10m'
BLUE='\033[38;5;4m'
YELLOW='\033[0;33m'
NC='\033[0m'

## Global variables
APP_NAME="$(${DIR}/read-yaml.sh docker.container_id)"
APP_HOST="$(${DIR}/read-yaml.sh docker.hostname)"
APP_NETWORK=${APP_NAME}_network

DOCKER_COMPOSE_YML="${DIR}/../.docker/docker-compose.yml.${APP_NAME}"
DOCKER_COMPOSE="docker-compose --project-name=${APP_NAME} -f ${DOCKER_COMPOSE_YML}"

QUIET=0

while [ "$1" != "" ]; do
  case $1 in
    -p | --project )
      shift
      APP_NAME=$1
      APP_NETWORK=${APP_NAME}_network
      ;;
    -q | --quiet )
      QUIET=1
      ;;
    -h | --help )
      usage
      exit
      ;;
    -nc | --no-colors )
      RED=''
      GREEN=''
      YELLOW=''
      BLUE=''
      NC=''
      ;;
    * )
      break
  esac
  shift
done