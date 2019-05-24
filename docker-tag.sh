#!/bin/bash

git pull

REPO=$(git config --get remote.origin.url | sed -E "s&^(ssh://|git@)git.innova-partners.com[/:]([A-Za-z0-9_/-]*)(.git)?$&\2&g")
BRANCH=master #$(git branch | grep \* | cut -d ' ' -f2)
COMMIT_HASH=$(git log -1 --pretty=%h)

# Tag the current image using the hash, branch, and latest
docker tag local/$REPO:latest registry.cmmint.net/$REPO:$COMMIT_HASH
docker tag local/$REPO:latest registry.cmmint.net/$REPO:$BRANCH
docker tag local/$REPO:latest registry.cmmint.net/$REPO:latest
docker push registry.cmmint.net/$REPO:$COMMIT_HASH
docker push registry.cmmint.net/$REPO:$BRANCH
docker push registry.cmmint.net/$REPO:latest

