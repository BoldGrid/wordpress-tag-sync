# Github to WordPress.org Tag Sync

This script is intended to be used to create a tag in the Wordpress.org SVN repo when after your
build succeeds via Travis.

## Getting started

### Install the package

```
yarn add @boldgrid/wordpress-tag-sync --dev
```

### Update your travis.yml

Adding the following snippet will run the script after your build finishes on tag builds. Note: If
you have multiple builds for different environments you may need to specify a condition so that the
tag isn't copied multiple times: See:
[Travis deployment conditions](https://docs.travis-ci.com/user/deployment/#Conditional-Releases-with-on%3A)

```
deploy:
  - provider: script
    script: chmod +x ./node_modules/@boldgrid/wordpress-tag-sync/release.sh && ./node_modules/@boldgrid/wordpress-tag-sync/release.sh
    skip_cleanup: true
    on:
      tags: true
```

### Update your Travis env variables

In order to commit the tag to WordPress you'll need to set 3 environment variables for the script.
These values can be set within the Travis interface. Make sure to leave the password as a hidden to
enable it as an encrypted environment variable.

Travis Output:

```
export WP_SVN_REPO=svn-repo-url
export WP_USERNAME=your-username
export WP_PASSWORD=password
```

### Release Archive (extra)

Additionally the script will create a zip file of the build which you can automatically upload to
your release via Travis. Add the following to your Travis configuration under deploy. You'll have to
provide the GitHub token via the Travis interface as an environment variable. The zip file will be
named the basename of your WordPress repo.

```
- provider: releases
  api_key: "${GITHUB_TOKEN}"
  file: "plugin-name.zip"
  skip_cleanup: true
  on:
	tags: true
```

### DONE

Travis will now update your tags in svn after build success. In order to change your stable tag you
will need a separate process to copy a given tag to trunk. Included in this package is deploy.sh, which
can issue that copy command. You can run it manually or in the Travis process.

Based on the following repo:
[https://github.com/mikejolley/github-to-wordpress-deploy-script](https://github.com/mikejolley/github-to-wordpress-deploy-script)
