#!/bin/sh

pwd="$PWD"
cd chia-blockchain
. ./activate
cd chia-blockchain-gui
npm run electron &
cd $pwd

