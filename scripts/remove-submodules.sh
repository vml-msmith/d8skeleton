#!/bin/bash

error() {
  local parent_lineno="$1"
  local message="$2"
  local code="${3:-1}"
  local me=`basename "$0"`
  if [[ -n "$message" ]] ; then
    echo "Error in ${me} on or near line ${parent_lineno}: ${message}; exiting with status ${code}"
  else
    echo "Error in ${me} on or near line ${parent_lineno}; exiting with status ${code}"
  fi
  exit "${code}"
}

trap 'error ${LINENO}' ERR

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -d "$f/.git" ]
then
   git rm "${DIR}/../.gitmodules"
fi

MODULES_FOLDER="${DIR}/../docroot/modules/contrib/*"
for f in $MODULES_FOLDER
do
    if [ -d "$f/.git" ]
    then
        git rm -rf --cached "$f" || true
        rm -rfdv "$f/.git"
    fi
done

THEMES_FOLDER="${DIR}/../docroot/themes/contrib/*"
for f in $THEMES_FOLDER
do
    if [ -d "$f/.git" ]
    then
        git rm -rf --cached "$f"
        rm -rfdv "$f/.git"
    fi
done
