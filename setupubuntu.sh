#!/bin/bash -e
# exit on first error

# reduce swapping, default 60
if [ ! -f /etc/sysctl.d/60-swappiness.conf ]
then
	echo "vm.swappiness = 10" > /etc/sysctl.d/60-swappiness.conf # permanent
	chmod a+r /etc/sysctl.d/60-swappiness.conf
	sysctl vm.swappiness=10 # temporary on the fly change
fi

# 32 bit libs for some legacy apps (e.g. jdgui)
apt-get install ia32-libs

# for virtualbox kernel module support
apt-get install "linux-headers-$(uname -r)"
apt-get install dkms

# groovy
apt-get install groovy

# cli utilities
apt-get install vim vim-gnome
apt-get install curl
apt-get install rdesktop
apt-get install ant
apt-get install flip
apt-get install libxml2-utils  # xmllint
apt-get install sshfs
#apt-get install cryptsetup     # ecryptfs-setup-swap

# scm
add-apt-repository ppa:git-core/ppa # ubuntu git maintainers
apt-get update
apt-get install git git-gui gitk
apt-get install subversion
apt-get install mercurial

# services
apt-get install apache2        # httpd
apt-get install openssh-server # sshd

# apps
apt-get install openjdk-7-jdk
apt-get install openjdk-6-jdk
apt-get install default-jdk
apt-get install pidgin
apt-get install synaptic       # synaptic package manager
apt-get install compizconfig-settings-manager # ccsm
apt-get install compiz-plugins # extra compiz settings e.g. Window Rules
apt-get install wireshark
apt-get install nmap

# third party apps

if [ ! -f /etc/apt/sources.list.d/google-chrome.list ]
then
	wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
	echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list
	chmod a+r /etc/apt/sources.list.d/google-chrome.list
	apt-get update
fi
apt-get install google-chrome-stable

if [ ! -f /etc/apt/sources.list.d/virtualbox.list ]
then
	wget -q -O - http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add -
	echo "deb http://download.virtualbox.org/virtualbox/debian quantal contrib" >> /etc/apt/sources.list.d/virtualbox.list
	chmod a+r /etc/apt/sources.list.d/virtualbox.list
	apt-get update
fi
apt-get install virtualbox-4.2
