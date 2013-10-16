#!/bin/sh

for f in ./*
do
  echo "Processing $f"
  cd $f
  git commit -a -m "Automatically generated commit message ($f)."
  cd ..
done
