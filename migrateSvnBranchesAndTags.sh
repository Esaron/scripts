#!/bin/bash

if [ $# != 1 ]; then
  echo "Need exactly one arg (git stage repo)"
  exit
fi

cd $1
convertSvnBranches.sh .
convertSvnTags.sh .
cd -
