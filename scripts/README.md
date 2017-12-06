## dcomposer.sh
A script that simplifies running composer commands from the Composer dockerfile. Just run

Example:

````
./scripts/dcomposer.sh require drupal/views
./scripts/dcomposer.sh update

````

## download-drupal.sh
Script that sets up the Drupal repo with Composer, updates the Composer registry and downloads all the actual files.

````
./scripts/download-drupal.sh

````

## install-drupal.sh
Script that installs the Drupal database, the same as if you were installing Drupal from the UI. All parameters are configured via the environments.yml file in the root directory of the repo.

````
./scripts/install-drupal.sh
````

## read-yaml.sh
Utility script to read environments.yml and pull out a specific value. This script is used by other scripts in this directory.

````
./scripts/read-yaml.sh drupal.site_name
./scripts/read-yaml.sh docker.container_id
````

## run-docker.sh
Run the Docker container. This will use values from environment.yml in the root of the repo. A docker-compose.yml.<DockerContainerID> file will be created in ../.docker/ that is a copy of ../.docker/docker-compose.yml.default, with the correct values from environment.yml substituted.

Once the server launches, your default browser will launch with the site.

**NOTE:** This command will fail if there is no docroot directory in the root of this repo. You should run ```./scripts/download-drupal``` before this one if your project has note been setup yet.

```
./scripts/run-docker.sh
```

## test-docker.sh
Test script to ensure the docker-compose.yml.default file and Dockerfile's are setup correctly and are working.

```
./scripts/test-docker.sh
```

## start-proxy.sh
Starts the nginx proxy. The proxy allows containers to be accessed via the domain name setup for the project in environment.yml. The proxy must be running before the project's docker containers are started.

**Note:** The domain name being used must exist in your /etc/hosts file.


```
./scripts/start-proxy.sh
```

## phpunit.sh
Run Drupal's phpunit script. This will automatically add some defaults, specifically ```--sqlite tmp/test.sqlite --verbose --non-html --color --php /usr/bin/php --concurrency 15```. Any argument you pass to this script will be passed to the end of the php unit command.

```
./scripts/phpunit.sh --list
./scripts/phpunit.sh MyTestGroup
```

## codecept.sh
Run the Codeception program for integration tests. You must do a ```codecept bootstrap``` before trying to run any tests. Quick Start for Codeception can be found here: [http://codeception.com/quickstart](http://codeception.com/quickstart)

```
./scripts/codecept.sh bootstrap
./scripts/codecept.sh generate:cept acceptance MyFirstAcceptanceTest
./scripts/codecept.sh run
```