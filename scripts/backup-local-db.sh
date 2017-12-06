#!/bin/bash

## Help function
usage() {
  SCRIPT="backup-local-db.sh"
  echo "$SCRIPT creates a local database backup."
  print_help_header "Examples"
  print_help_columns "$SCRIPT" "Backs up local database to db_backup/[project].local.sql"
  print_help_columns "$SCRIPT --name [name]" "Backs up local database to db_backup/[project].local.[name].sql"
  print_global_help_options
  print_help_header "Options"
  print_help_columns "--name" "Set additional identifier in filename."
}

## Shared functions
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/functions.sh"
source "$DIR/spinner.sh"

## Error handling
trap 'error ${LINENO}' ERR

## Script default variables
FILE=db_backup/${APP_NAME}.local.sql

## Script options
while [ "$1" != "" ]; do
  case $1 in
    --name )
      shift
      FILE=db_backup/${APP_NAME}.local.${1}.sql
      ;;
    * )
      break
  esac
  shift
done

## Main script
print_header "LOCAL DATABASE BACKUP"
print_update "Namespace: ${APP_NAME}"
print_update "Filename: ${FILE}"

## Make backup dir if it does not already exist
mkdir -p db_backup

start_spinner "Dumping database..."
$DIR/ddrush.sh --project ${APP_NAME} --quiet sql-dump > ${FILE}
stop_spinner