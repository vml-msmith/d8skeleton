#!/bin/bash

## Help function
usage() {
  SCRIPT="lint.sh"
  echo "$SCRIPT runs lint checker against code."
  print_help_header "Examples"
  print_help_columns "$SCRIPT" "Runs linter against features and custom modules."
  print_help_columns "$SCRIPT [files]" "Runs linter against specified files."
  print_help_header "Arguments"
  print_help_columns "files" "space seperated list of files to lint."
  print_global_help_options
}

## Shared functions
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/functions.sh"

## Error handling
trap 'error ${LINENO}' ERR

## Main script
print_header "LINTER"
print_update "Namespace: ${APP_NAME}"

if [[ -z "$@" ]]; then
  print_error "Nothing to do"
  exit;
fi

print_status "Starting docker container..."
${DOCKER_COMPOSE} run linter ${@}

docker_cleanup "linter_run"

