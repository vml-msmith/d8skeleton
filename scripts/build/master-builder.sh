echo "Pull & Build Master"
TAG=$BUILD_TIMESTAMP-$BUILD_NUMBER
#TAG="FIRST-TAG"
ASSET_TAG="${TAG}-Asset"

git tag -d $TAG
git tag -d $ASSET_TAG

git clean -fd

git checkout master
git pull origin master

git push acquia master
git fetch acquia
git checkout acquia-master
git pull acquia acquia-master

git merge -X theirs master

## Remove contrib modules and themes.
rm -rf docroot/modules/contrib/ docroot/themes/contrib/

sh ./scripts/dcomposer.sh --jenkins install --prefer-dist --no-dev -o

## Setup docker containers.
#sh ./scripts/run-docker.sh

## Create new tag.
git tag -a $TAG -m "Jenkins build $BUILD_DISPLAY_NAME" -m "$BUILD_URL"
git push origin $TAG
git push acquia $TAG

## Run front end build systems.
sh ./scripts/gulp.sh -p=npm -p=gulp-build

echo "Done building theme"


## Remove Git submodule folders.
sh ./scripts/remove-submodules.sh

git add docroot --force
git add vendor --force

git status

if git diff-index --quiet HEAD --; then
    echo "Nothing to commit."
else
    git commit -m "Adding compiled assets." --no-verify
fi


git push acquia acquia-master

git tag -a $ASSET_TAG -m "Jenkins build $BUILD_DISPLAY_NAME with compiled assets" -m "$BUILD_URL"
git push acquia $ASSET_TAG

sh ./scripts/stop-docker.sh

HOME=$(pwd)
#drush @tnvacation.dev ac-code-path-deploy --email=ben.summers@vml.com --key=kBUoq3ybZ8D6oq4LGUhPAeSFgyBQ7MIN/UPcnsdjQUaG6SaIm0UFot5A5D13RcRVGHEufXdxf23F tags/${ASSET_TAG}
