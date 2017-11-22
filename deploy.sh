#!/usr/bin/env bash

svnmucc
	rm ${WP_SVN_REPO}"/trunk"
	cp HEAD ${WP_SVN_REPO}"/tags/"${TAG_NUMBER} ${WP_SVN_REPO}"/trunk"
	-m "Deploy stable tag"
	--username=$WP_USERNAME --password=$WP_PASSWORD
