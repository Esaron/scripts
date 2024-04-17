#!/bin/bash

# Replace:
#  Arg 1: To replace
#  Arg 2: Replace with
#  Arg 3+: Target dirs/files (default to current)

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
echo "$TARGETS"

find $TARGETS -type f -exec sed -i '' -e "s/$TOREPLACE/$REPLACEMENT/g" {} +

