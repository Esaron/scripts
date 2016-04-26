#!/bin/bash

# This is the worst thing ever and I am terrible for not writing this better.  I need something fast.

if [ $# -ne '3' ]
then
    echo >&2 "Usage: genFiles.sh dir numberofdirectories numberoffiles"
    exit 1
fi

maxBlockSize=5
blockSize=8192

function randomSize {
  local size=$RANDOM
  let "size %= $maxBlockSize * $blockSize"
  echo $size
}

pushd $1
numDirs=$2
numFiles=$3
for i in $(seq 1 $numDirs); do
  mkdir $i
  pushd $i >/dev/null
  for j in $(seq 1 $numFiles); do
    size=$(randomSize)
    str=$(printf "%-${size}s" "X")
    echo "${str// /*}" >> $j
  done
  popd >/dev/null
done
popd >/dev/null
