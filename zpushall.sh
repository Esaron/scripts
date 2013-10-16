#!/bin/sh

for f in ./*
do
  echo "Processing $f"
  cd $f
  git push
  cd ..
done
