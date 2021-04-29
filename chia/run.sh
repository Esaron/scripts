#!/bin/bash

cd ~/chia/chia-blockchain

# venv
. ./activate

# run harvester
chia start harvester -r

