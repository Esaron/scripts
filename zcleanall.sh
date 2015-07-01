#!/bin/sh

for f in $1/*
do
  echo "Processing $f"
  cd $f
  git clean-all -f
  cd ..
  echo
done
