#!/bin/sh

sudo apt-get update
sudo apt-get upgrade -y

# Checkout the source and install
git clone https://github.com/Chia-Network/chia-blockchain.git -b latest
cd chia-blockchain

sh install.sh

. ./activate

# The GUI requires you have Ubuntu Desktop or a similar windowing system installed.
# You can not install and run the GUI as root

sh install-gui.sh

