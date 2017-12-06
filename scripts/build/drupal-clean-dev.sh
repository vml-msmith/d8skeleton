#!/bin/bash
echo Cleaning Drupal...

OLDHOME=$HOME
HOME=$(pwd)

drush @tnvacation.dev cr
drush @tnvacation.dev pm-enable envmod -y
drush @tnvacation.dev switch-environment dev
drush @tnvacation.dev updatedb -y
drush @tnvacation.dev entup -y
drush @tnvacation.dev fim tn_vacation_core -y
drush @tnvacation.dev fia -y
drush @tnvacation.dev cr
drush @tnvacation.dev ac-domain-purge --email=michael.smith@vml.com --key=InHAt0hp3MXdAtqlmgo3RPONVMFWTJnWn4itVdu1KE/lsEWNUFFqT3HTMgou3G5E9u4iQDZvAvh+ tnvacationdev.prod.acquia-sites.com

HOME=$OLDHOME