#!/usr/bin/env bash

# Based on work by Mike Jolley, based on work by Barry Kooij
# License: GPL v2

set -e

# ASK INFO
echo "--------------------------------------------"
echo "      Github to WordPress.org RELEASER      "
echo "--------------------------------------------"

# VARS
VERSION=$(git describe --exact-match --tags $(git log -n1 --pretty='%h'))
CI_BUILD_PATH=$(pwd)"/"
SVN_DIR="tmp-repo-svn"
SVN_WORKSPACE=${CI_BUILD_PATH}${SVN_DIR}
VERSION_PATH=$SVN_WORKSPACE"/tags/"${VERSION}
PLUGIN_NAME=$(basename ${WP_SVN_REPO})

echo "Releasing Version: ${VERSION}";
echo "Using Plugin Name: ${PLUGIN_NAME}"

# CHECKOUT SVN DIR IF NOT EXISTS
rm -f $PLUGIN_NAME".zip"
rm -Rf $PLUGIN_NAME
rm -Rf $SVN_DIR

echo "Deleting Old Tag"
svn delete ${WP_SVN_REPO}/tags/${VERSION} -m "Remove Old Tag" --username=$WP_USERNAME --password=$WP_PASSWORD --non-interactive --no-auth-cache || echo "Old tag not found.";

echo "Creating New Tag"
svn cp $WP_SVN_REPO/trunk ${WP_SVN_REPO}/tags/${VERSION} -m "New tag" --username=$WP_USERNAME --password=$WP_PASSWORD --non-interactive --no-auth-cache

echo "Checking out WordPress.org plugin repository"
svn checkout $WP_SVN_REPO $SVN_DIR --depth immediates || { echo "Unable to checkout repo."; exit 1; }

# MOVE INTO SVN DIR
cd $SVN_WORKSPACE

# UPDATE SVN
echo "Updating SVN tag"
svn update "tags/"${VERSION} --set-depth infinity || { echo "Unable to update SVN."; exit 1; }

echo "Delete trunk files"
rm -Rf $VERSION_PATH
mkdir $VERSION_PATH

echo "Copy repo files to working dir"
shopt -s extglob
cp -prf ${CI_BUILD_PATH}!(node_modules|${SVN_DIR}) $VERSION_PATH
shopt -u extglob

cd $VERSION_PATH

# REMOVE UNWANTED FILES & FOLDERS
echo "Removing unwanted files"
rm -Rf .git
rm -Rf .github
rm -Rf tests
rm -Rf apigen
rm -Rf coverage
rm -Rf node_modules
rm -Rf bin
rm -Rf tools
rm -Rf bower_components
rm -f .gitattributes
rm -f .gitignore
rm -f .gitmodules
rm -f .travis.yml
rm -f release.sh
rm -f Gruntfile.js
rm -f gulpfile.js
rm -f bower.json
rm -f karma.conf.js
rm -f karma.config.js
rm -f yarn.lock
rm -f webpack.config.js
rm -f package.json
rm -f .jscrsrc
rm -f .jshintrc
rm -f composer.json
rm -f composer.lock
rm -f phpunit.xml
rm -f phpunit.xml.dist
rm -f README.md
rm -f .coveralls.yml
rm -f .editorconfig
rm -f .scrutinizer.yml
rm -f apigen.neon
rm -f CHANGELOG.txt
rm -f stylelint.config.js
rm -f .stylelintignore
rm -f CONTRIBUTING.md

cd $SVN_WORKSPACE

# DO THE ADD ALL NOT KNOWN FILES UNIX COMMAND
svn add --force * --auto-props --parents --depth infinity -q

# DO THE REMOVE ALL DELETED FILES UNIX COMMAND
MISSING_PATHS=$( svn status | sed -e '/^!/!d' -e 's/^!//' )

# iterate over filepaths
for MISSING_PATH in $MISSING_PATHS; do
    svn rm --force "$MISSING_PATH"
done

# Find all "unexpectedly changed kind" items (ie: symlink to file).
CHANGED_PATHS=$( svn status | sed -e '/^~/!d' -e 's/^~//' )

# Iterate over changed type filepaths.
for CHANGED_PATH in $CHANGED_PATHS; do
    mv "$CHANGED_PATH" "$CHANGED_PATH.TEMP0"
    svn rm --force "$CHANGED_PATH"
    mv "$CHANGED_PATHS.TEMP0" "$CHANGED_PATH"
    svn add --force "$CHANGED_PATH"
done

# DO SVN COMMIT
clear
echo "Showing SVN status"
svn status

# DEPLOY
echo ""
echo "Committing to WordPress.org...this may take a while..."
svn commit -m "Release "${VERSION}", see readme.txt for the changelog." --username=$WP_USERNAME --password=$WP_PASSWORD --non-interactive --no-auth-cache || { echo "Unable to commit."; exit 1; }

echo "Zip output"
cd $CI_BUILD_PATH
mv $VERSION_PATH $PLUGIN_NAME
zip -rq $PLUGIN_NAME".zip" $PLUGIN_NAME"/"
rm -Rf $PLUGIN_NAME
echo "Created: "$PLUGIN_NAME".zip"

echo "Cleanup"
rm -Rf $SVN_WORKSPACE

# DONE, BYE
echo "RELEASER DONE :D"
