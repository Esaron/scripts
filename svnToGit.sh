#!/bin/bash

if [ $# != 1 ]; then
  echo "Need exactly one arg (svn repo)"
  exit
fi

REPO="$1"
DIR=`echo ${REPO##*/}`

getSvnAuthors.sh "$REPO"
git svn clone --stdlayout --authors-file=authors.txt "$REPO"
migrateSvnBranchesAndTags.sh "$DIR"
