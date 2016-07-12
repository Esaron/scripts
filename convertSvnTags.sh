#!/bin/bash

if [ $# != 1 ]; then
  echo "Need exactly one arg (git stage repo)"
  exit
fi

cd $1
for tag in `git branch -r | grep "origin/tags/"`; do
  git tag -a -m "Converting SVN tags to GIT" `echo $tag | sed 's|origin/tags/||'` refs/remotes/$tag
  git branch -D `echo "$tag" | sed 's|origin/||'`
done
cd -
