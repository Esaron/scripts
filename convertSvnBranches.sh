#!/bin/bash

if [ $# != 1 ]; then
  echo "Need exactly one arg (git stage repo)"
  exit
fi

cd $1
for branch in `git branch -r`; do
  git branch `echo $branch | sed 's|origin/||'` refs/remotes/$branch
done
git branch -D trunk
cd -
