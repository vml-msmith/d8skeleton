PROJECT=prlocal

git pull origin development
git status

# merge in new code to build from (take incoming for conflicts)
#git merge -X theirs --ff $SOURCE_BRANCH --no-commit

./scripts/run-docker.sh ${PROJECT}

composer install --prefer-dist --no-dev -o --verbose

OLDHOME=$HOME
HOME=$(pwd)

## Import DB and Files from Dev

echo Database Dump...
drush @tnvacation.dev sql-dump > $HOME/tnvacation.dev.sql
sleep 3
echo Importing Databse...
$HOME/scripts/envsync.sh dev --project ${PROJECT} --no-files

./scripts/kill-docker.sh ${PROJECT}

git status
HOME=$OLDHOME