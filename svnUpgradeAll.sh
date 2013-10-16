#!/bin/sh

for f in $1/*
do
  echo "SVN Upgrade: $f"
  cd $f
  svn upgrade
  cd ..
done
