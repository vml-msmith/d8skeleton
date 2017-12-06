#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

APP_NAME="$(${DIR}/read-yaml.sh docker.container_id)"
SITE_NAME="$(${DIR}/read-yaml.sh drupal.site_name)"
SITE_MAIL="$(${DIR}/read-yaml.sh drupal.site_mail)"
ADMIN_ACCOUNT_NAME="$(${DIR}/read-yaml.sh drupal.admin_account_name)"
ADMIN_ACCOUNT_PASS="$(${DIR}/read-yaml.sh drupal.admin_account_pass)"
PROFILE="$(${DIR}/read-yaml.sh drupal.profile)"

CMD="cd /var/www/docroot; /var/www/vendor/bin/drupal site:install {$PROFILE} --site-name \"${SITE_NAME}\" --db-type mysql --db-port 3306 --db-user root --db-prefix=\"\" --db-pass root --db-host mysql --db-name drupal --langcode en --site-mail ${SITE_MAIL} --account-name ${ADMIN_ACCOUNT_NAME} --account-mail ${SITE_MAIL} --account-pass ${ADMIN_ACCOUNT_PASS}"


docker exec -it ${APP_NAME}_main_1 bash -c "${CMD}"
