#!/bin/sh

for f in $1/*
do
  echo "Processing $f"
  cd $f
  ant resolve
  cd ..
done
