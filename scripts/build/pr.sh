# Start the whole thing off by making sure the two branches can merge, install composer and npm, run lint.

echo "Source: ${sourceBranch}"
echo "Taret: ${targetBranch}"

SOURCE_BRANCH="${sourceBranch}"
TARGET_BRANCH="${targetBranch}"

PROJECT=pr`date +"%s"`

git fetch
git status

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


## Import DB and Files from Dev

## Environment sync
##./scripts/envsync.sh dev --project ${PROJECT} --no-confirm --no-files

./scripts/kill-docker.sh ${PROJECT}

rm .docker/docker-compose.yml.pr*
git status
HOME=$OLDHOME
