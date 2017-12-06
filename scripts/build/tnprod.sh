echo "Deploy to Prod"
HOME=$(pwd)
drush @tnvacation.prod ac-code-path-deploy --email=ben.summers@vml.com --key=kBUoq3ybZ8D6oq4LGUhPAeSFgyBQ7MIN/UPcnsdjQUaG6SaIm0UFot5A5D13RcRVGHEufXdxf23F ${GIT_TAG}