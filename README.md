# Github to WordPress.org Tag Sync

This script is intended to be used to create a tag in the Wordpress.org svn repo when after your
build succeeds via travis.

## Getting started

### Install the package

```
yarn add wordpress-tag-sync --dev
```

### Update your travis.yml

Adding the following snippet will run the script after your build finishes on tag builds. Note: if
you have multiple build for different environments you may need to specify a condition: See:
[Travis deployment conditions](https://docs.travis-ci.com/user/deployment/#Conditional-Releases-with-on%3A)

```
deploy:
  provider: script
  script: chmod +x ./node_modules/wordpress-tag-sync/release.sh && ./node_modules/wordpress-tag-sync/release.sh
  skip_cleanup: true
  on:
    tags: true
```
