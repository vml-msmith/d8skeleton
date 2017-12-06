# Start the whole thing off by making sure the two branches can merge, install composer and npm, run lint.

echo "Source: ${sourceBranch}"
echo "Taret: ${targetBranch}"

SOURCE_BRANCH="${sourceBranch}"
TARGET_BRANCH="${targetBranch}"

PROJECT=pr`date +"%s"`

git fetch
git status
#git checkout ${targetBranch}
#git pull origin ${targetBranch}

## checkout the branch we're going to merge to.
export BRANCH=pull-request/$pullRequestId

git branch -D $BRANCH || :
git checkout -b $BRANCH

# merge in new code to build from (take incoming for conflicts)
#git merge -X theirs --ff $SOURCE_BRANCH --no-commit

./scripts/run-docker.sh ${PROJECT}

# composer install --prefer-dist --no-dev -o --verbose
sh ./scripts/dcomposer.sh --jenkins install --prefer-dist --no-dev -o --verbose

git status

git merge-base ${BRANCH} ${targetBranch}

./hooks/pre-commit ${BRANCH} $TARGET_BRANCH

## Run Unit Tests
#sh ./scripts/phpunit.sh tnv

OLDHOME=$HOME
HOME=$(pwd)

##./scripts/ddrush.sh 'sql-cli < /var/www/tnvacation.dev.sql'


## Import DB and Files from Dev

echo Database Dump...
# drush @tnvacation.dev sql-dump > $HOME/tnvacation.dev.sql
# sleep 3
echo Importing Databse...
# $HOME/scripts/ddrush.sh --project ${PROJECT} "sql-cli < /var/www/tnvacation.dev.sql"
## Check Feature Imports
echo Database Updates...
# $HOME/scripts/ddrush.sh --project ${PROJECT} "updatedb -y"
echo Enable ENV MOD...
# $HOME/scripts/ddrush.sh --project ${PROJECT} "pm-enable envmod -y"
echo Install Modules...
# $HOME/scripts/ddrush.sh --project ${PROJECT} "switch-environment dev"
echo Feature Import...
# $HOME/scripts/ddrush.sh --project ${PROJECT} "fia -y"
echo Cache Clear...
# $HOME/scripts/ddrush.sh --project ${PROJECT} "cr"

## Environment sync
./scripts/envsync.sh dev --project ${PROJECT} --no-confirm --no-files

./scripts/kill-docker.sh ${PROJECT}

rm .docker/docker-compose.yml.pr*
git status
HOME=$OLDHOME