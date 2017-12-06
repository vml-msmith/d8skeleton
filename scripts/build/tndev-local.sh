echo "Pull & Build Dev"

TAG=`date +"%Y%m%d-%H%M%S"`-LOCAL
ASSET_TAG="${TAG}-Asset"

BUILD_DISPLAY_NAME="LOCAL"
BUILD_URL="none"

./scripts/postToSlack.sh -s "good" -t "Local Dev Build" -b "Build started." -c "technology-ops" -u "https://hooks.slack.com/services/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"

git clean -fd

git fetch origin
git checkout development
git pull origin development

git push -f acquia development
git fetch acquia
git checkout acquia-development
git pull acquia acquia-development

git merge -X theirs development -m 'merged'

## Remove contrib modules and themes.
## rm -rf docroot/modules/contrib/ docroot/themes/contrib/

sh ./scripts/dcomposer.sh --jenkins install --prefer-dist --no-dev -o --verbose

## Setup docker containers.
sh ./scripts/run-docker.sh tndev

## Create new tag.
git tag -a $TAG -m "Jenkins build $BUILD_DISPLAY_NAME" -m "$BUILD_URL"
git push origin $TAG
git push acquia $TAG

## Run front end build systems.
sh ./scripts/gulp.sh -p=bower -p=npm -p=gulp-build

## Remove Git submodule folders.
sh ./scripts/remove-submodules.sh

## Add changes.
git add . --force
git status

if git diff-index --quiet HEAD --; then
    echo "Nothing to commit."
else
  git commit -m "Adding compiled assets."
fi
git push acquia acquia-development

git tag -a $ASSET_TAG -m "Jenkins build $BUILD_DISPLAY_NAME with compiled assets" -m "$BUILD_URL"
git push acquia $ASSET_TAG

sh ./scripts/kill-docker.sh tndev

echo Sleeping...
sleep 30
sh ./scripts/build/drupal-clean-dev.sh
sh ./scripts/build/drupal-clean-stage.sh


git fetch origin
git checkout development

./scripts/postToSlack.sh -s "good" -t "Local Dev Build" -b "Build complete: SUCCESS" -c "technology-ops" -u "https://hooks.slack.com/services/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"
