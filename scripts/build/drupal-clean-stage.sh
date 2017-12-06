#!/bin/bash
echo Cleaning Drupal...

OLDHOME=$HOME
HOME=$(pwd)

drush @tnvacation.test cr
drush @tnvacation.test pm-enable envmod -y
drush @tnvacation.test switch-environment stage
drush @tnvacation.test updatedb -y
drush @tnvacation.test entup -y
drush @tnvacation.test fim tn_vacation_core -y
drush @tnvacation.test fia -y
drush @tnvacation.test cr

drush @tnvacation.test ac-domain-purge --email=ben.summers@vml.com --key=kBUoq3ybZ8D6oq4LGUhPAeSFgyBQ7MIN/UPcnsdjQUaG6SaIm0UFot5A5D13RcRVGHEufXdxf23F tnvacationstg.prod.acquia-sites.com

HOME=$OLDHOME