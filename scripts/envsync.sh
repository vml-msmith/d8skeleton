#!/bin/bash

## Help function
usage() {
  SCRIPT="envsync.sh"
  echo "$SCRIPT pulls down a remote drupal database and files then runs some cleanup scripts."

  print_help_header "Examples"
  print_help_columns "$SCRIPT dev" "Pull database and files from development and import them into local."
  print_help_header "Arguments"
  print_help_columns "environment" "Environment to sync. (dev|stage|prod)"
  print_global_help_options
  print_help_header "Options"
  print_help_columns "--no-confirm" "Skip confirmation."
  print_help_columns "--no-dump" "Skip database dump from remote environment."
  print_help_columns "--no-import" "Skip database import."
  print_help_columns "--no-files" "Skip file sync from remote environment."
  print_help_columns "--no-composer" "Skip composer install."
  print_help_columns "--no-reset" "Skip drupal-reset script execution."
}

## Shared functions
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/functions.sh"

## Error handling
trap 'error ${LINENO}' ERR

## Script default variables
CONFIRMED=0
NO_CONFIRM=0
NO_DUMP=0
NO_IMPORT=0
NO_FILES=0
NO_COMPOSER=0
NO_RESET=0

## Script options
while [ "$1" != "" ]; do
  case $1 in
    --no-confirm )
      NO_CONFIRM=1
      CONFIRMED=1
      ;;
    --no-dump )
      NO_DUMP=1
      ;;
    --no-import )
      NO_IMPORT=1
      ;;
    --no-files )
      NO_FILES=1
      ;;
    --no-composer )
      NO_COMPOSER=1
      ;;
    --no-reset )
      NO_RESET=1
      ;;
    * )
      break
  esac
  shift
done

## Script variables
ENVIRONMENT=$1
ALIAS="$(${DIR}/read-yaml.sh drush.aliases.$ENVIRONMENT)"

if [ -z $ALIAS ]; then
  print_error "No drush alias found for $ENVIRONMENT"
  exit 1
fi

## Database file
FILE=db_backup/${ALIAS}.sql
## Make backup dir if it does not already exist
mkdir -p db_backup

## Main script
print_header "ENVIRONMENT SYNC"
print_update "Namespace: ${APP_NAME}"
print_update "Target Environment: ${ENVIRONMENT}"

if [ $NO_CONFIRM == 0 ]; then
  read -p "This will overwrite your docker database and your sites/default/files directory. Are you sure?" -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    CONFIRMED=1
  fi
fi
echo ""

if [[ $CONFIRMED == 1 ]]; then
	if [ $NO_DUMP == 0 ]; then
		print_status "Dumping database..."
		drush @${ALIAS} sql-dump --skip-tables-key=common > ${FILE}
		echo Created backup at ${FILE}
	fi

	if [ $NO_IMPORT == 0 ]; then
		if [ -f "$FILE" ];
		then
			print_status "Importing database..."
      $DIR/ddrush.sh --project ${APP_NAME} --quiet 'sql-drop --yes'
      $DIR/ddrush.sh --project ${APP_NAME} --quiet "sql-cli < /var/www/${FILE}"
		else
			print_error "$FILE not found."
      exit 1
		fi
	fi

	if [ $NO_FILES == 0 ]; then
		print_status "Syncing files..."
		drush -y rsync --progress -v @${ALIAS}:%files docroot/sites/default
	fi

  if [ $NO_COMPOSER == 0 ]; then
    print_status "Composer Install..."
    $DIR/dcomposer.sh --project ${APP_NAME} --quiet install --prefer-dist -v -o
  fi

  if [ $NO_RESET == 0 ]; then
    print_status "Resetting Drupal..."
    $DIR/drupal-reset.sh --project ${APP_NAME} --quiet
  fi

  print_header "ENVIRONMENT SYNC COMPLETE"
  
fi
