#!/bin/bash

GIT_SERVER="$1"
GIT_USER='git'
SERVER_GIT_DIR='/git'
GIT_BACKUP_DIR='/git'
cd $GIT_BACKUP_DIR
ls -F . | grep / > $GIT_BACKUP_DIR/.localRepos
ssh -p 29418 $GIT_SERVER 'gerrit ls-projects' > $GIT_BACKUP_DIR/.serverRepos
diff $GIT_BACKUP_DIR/.localRepos $GIT_BACKUP_DIR/.serverRepos | grep -oP "> \K(.*)" > $GIT_BACKUP_DIR/.newRepos
for f in `cat .newRepos`; do
  git clone --bare --mirror ssh://$GIT_USER@$GIT_SERVER:$SERVER_GIT_DIR/$f $f
done
for f in `cat .serverRepos`; do
  cd $f
  echo $f
  git fetch
  cd -
done
rm -f $GIT_BACKUP_DIR/.localRepos $GIT_BACKUP_DIR/.serverRepos $GIT_BACKUP_DIR/.newRepos
