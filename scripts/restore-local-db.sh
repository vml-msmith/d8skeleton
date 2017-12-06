#!/bin/bash

## Help function
usage() {
  SCRIPT="restore-local-db.sh"
  echo "$SCRIPT restores a local database backup."
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
CONFIRMED=0
NO_CONFIRM=0
FILE=db_backup/${APP_NAME}.local.sql

## Script options
while [ "$1" != "" ]; do
  case $1 in
    --no-confirm )
      NO_CONFIRM=1
      CONFIRMED=1
      ;;
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
print_header "LOCAL DATABASE RESTORE"
print_update "Namespace: ${APP_NAME}"
print_update "Filename: ${FILE}"

## Check for file
[ ! -f "$FILE" ] && { print_error "$FILE file not found."; exit 1; }

if [ $NO_CONFIRM == 0 ]; then
  read -p "This will overwrite your docker database. Are you sure?" -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    CONFIRMED=1
  fi
fi
echo ""

if [[ $CONFIRMED == 1 ]]; then
	start_spinner "Importing database..."
	$DIR/ddrush.sh --project ${APP_NAME} --quiet 'sql-cli < /var/www/'${FILE}
  stop_spinner
fi