#!/bin/bash

# spin down
cd ~/chia/chia-blockchain
. ./activate
chia stop -d all
deactivate

# update
git fetch
git checkout latest
git reset --hard FETCH_HEAD
sh install.sh

# venv
. ./activate

# reinit
chia init

# update gui
cd chia-blockchain-gui
git fetch
cd ..
sh install-gui.sh

