#!/bin/sh

for f in $1/*
do
  echo "Processing $f"
  cd $f
  git pull
  cd ..
done
