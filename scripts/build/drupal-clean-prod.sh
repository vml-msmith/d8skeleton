#!/bin/bash
echo Cleaning PRODUCTION Drupal...

OLDHOME=$HOME
HOME=$(pwd)

drush @tnvacation.prod cr
drush @tnvacation.prod pm-enable envmod -y
drush @tnvacation.prod switch-environment prod
drush @tnvacation.prod updatedb -y
drush @tnvacation.prod entup -y
drush @tnvacation.prod fim tn_vacation_core -y
drush @tnvacation.prod fia -y
drush @tnvacation.prod cr

HOME=$OLDHOME