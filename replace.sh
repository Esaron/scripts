#!/bin/bash

# Replace:
#  Arg 1: To replace
#  Arg 2: Replace with
#  Arg 3+: Target dirs/files (default to current)

if [[ $# < 2 ]]
then
  echo "Usage: replace toReplace replaceWith [targetDirs...]"
  exit 1
fi

TOREPLACE=$1
REPLACEMENT=$2
if [[ $TOREPLACE == */* || $REPLACEMENT == */* ]]
then
  echo "Error: Either TOREPLACE or REPLACE contains \"/\" used for sed pattern delimiter."
  exit 1
fi
shift 2

if [[ $# == 0 ]]
then
  TARGETS="."
else
  TARGETS="$@"
fi

echo "Replacing \"$TOREPLACE\" with \"$REPLACEMENT\" in all of the following:"
for target in $TARGETS
do
  echo "  $target"
done
find "$TARGETS" -type f -print0 | xargs -0 sed -i "s/$TOREPLACE/$REPLACEMENT/g"
