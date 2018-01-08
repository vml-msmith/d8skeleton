# README

## Local Drupal Setup
- Install Docksal
- Clone the Wendys.com repository from bitbucket: ssh://git@bitbucket-ssh.uhub.biz:7999/vmlnawen/wendys.com.git
 
  ```
  git clone ssh://git@bitbucket-ssh.uhub.biz:7999/vmlnawen/wendys.com.git wendys
  ```
- Change directory to the wendy's project:

  ```
  cd wendys
  ```
- Initialize the project's Docksal environment

  ```
  fin start
  ```
  
- Add local.wendys.com to your local hosts file:

  ```
  fin hosts add
  ```

- Download and setup the Wendy's database from the Development environment:
	- Login to insight.acquia.com
	- Select the Wendy's project.
	- Select the Development environment.
	- Select "Databases" from the left hand menu.
	- Download the latest database.
	- Save the file to local Downloads directory.
	- Install the DB to the Docksal environment
	
	  ```
	  fin db import ~/Dowloads/<downloadedFileName>.sql
	  ``` 

- Download Dev uploaded files(images) to local file system:

  ```
  rsync -azrltDvPh  wendys.dev@wendysdev.ssh.prod.acquia-sites.com:/mnt/files/wendysdev/sites/default/files/ docoot/sites/default/files/
  ```

- Create your own settings.local.php

   ```
	cp docroot/sites/default/settings.local.php.default docroot/sites/default/settings.local.php
   ```

- Setup Docksal utilities for building the site and compiling front end resources:

  ```
  fin util
  ```

- Download the Composer dependencies (**NOTE: Make sure you're in docroot**):

  ```
  cd docroot
  fin rc composer install --prefer-dist
  ```
  
- Compile front end assets:

  ```
  fin febuild npm
  fin febuild gulp-build
  ```
  
- Clear the local Drupal cache (**NOTE: Make sure you're in docroot**):

  ```
  cd docroot
  fin drush cr
  ```
  
## Update to latest from Dev:
- Download and setup the Wendy's database from the Development environment:
	- Login to insight.acquia.com
	- Select the Wendy's project.
	- Select the Development environment.
	- Select "Databases" from the left hand menu.
	- Download the latest database.
	- Save the file to local Downloads directory.
	- Install the DB to the Docksal environment
	
	  ```
	  fin db import ~/Dowloads/<downloadedFileName>.sql
	  ``` 

- Download Dev uploaded files(images) to local file system:

  ```
  rsync -azrltDvPh  wendys.dev@wendysdev.ssh.prod.acquia-sites.com:/mnt/files/wendysdev/sites/default/files/ docoot/sites/default/files/
  ```

- Clear the local Drupal cache (**NOTE: Make sure you're in docroot**):

  ```
  cd docroot
  fin drush cr
  ```

## Install Drupal Module:
- Install via composer:

   ```
   fin rc composer require drupal/<moduleName><versionSpecifier>
   ``` 
- Commit composer files to git.

  ```
  git add composer.json
  git add composer.lock
  git commit -m "Added new moduke <moduleName> for <x, y, z> reasons"
  ```
  
## Build Front End Assets
- On first build, make sure to install utilities and install npm packages.

  ```
  fin util
  fin febuild npm
  ```
  
- On subsequent builds, just run gulp

  ```
  fin febuild gulp-build
  ```

- Fix **ALL** warnings and noticies before committing code.

## Use Drush locally
  ```
  cd docroot
  fin drush <yourCommand>
  ```

## General Notes
### Front End
- Prefer not to use new twig templates for bricks/blocks/nodes/menus/etc. Instead use field groups and CSS to style.
- Use preprocess methods in wendys_main.theme to add classes when needed.
- Front end code is written in themesrc/wendys/, the compile process will move it to the correct theme location.
- SCSS for each Brick/Component on the page shoukd have it's own file defined in themesrc/wendys/styles/libraries.
- Each library should be it's own library in the wendys_main theme.
- ALWAYS work in mobile first.
- Prefer pre-built libraries instead of custom code where possible.
- Wrap your JavaScript in once() methods to ensure they're only fired once when necessary.

### Git
- **ALWAYS** fix warnings and notices before committing anything to Git.
- Prefer SMALL commits and SMALLL PRs to monolithic commits and PRs.
- All code should be committed to a feature branch and a pull request issued to master.
	- All feature branches should be tied to a ticket. Do not write code or configuration that isn't in a ticket.

	  ```
	  git checkout -b feature/VMLNAWEN-1-my-new-feature-that-does-what-ticket-1-says
	  git add
	  git commit -m "explanation of git"
	  git push origin feature/VMLNAWEN-1-my-new-feature-that-does-what-ticket-1-says
	  ```
	  
### Drupal Stuff
- Ensure that everything is translateable, nothing should ever be static text.
- Configuration uses config sync.
- Use B-Lazy for CSS background images and loading the correct image sizes.
- Prefer Media to File Fields. Every file should be uploaded as Media.
- Pay close attention to performance and speed. Everything should run very fast.
- The entire site will be Varnish cached, never rely on personalied blocks from Drupal/PHP unless the user is a logged in content author.


### QA
- As a developer, always QA your own code **AS THE USER THAT WILL USE THE FEATURE**. Make sure you look at how your component will look as an un-authenticated site visitor.
