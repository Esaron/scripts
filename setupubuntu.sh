#!/bin/bash -e
# exit on first error

function aptget() {
	apt-get -y --force-yes "$@"
}
function addaptrepository() {
	add-apt-repository -y "$@"
}

# reduce swapping, default 60
if [ ! -f /etc/sysctl.d/60-swappiness.conf ]
then
	echo "vm.swappiness = 10" > /etc/sysctl.d/60-swappiness.conf # permanent
	chmod a+r /etc/sysctl.d/60-swappiness.conf
	sysctl vm.swappiness=10 # temporary on the fly change
fi

# 32 bit libs for some legacy apps (e.g. jdgui)
aptget install ia32-libs

# for virtualbox kernel module support
aptget install "linux-headers-$(uname -r)"
aptget install dkms

# cli utilities
aptget install vim vim-gnome
aptget install curl
aptget install rdesktop
aptget install ant
aptget install flip
aptget install libxml2-utils  # xmllint
aptget install sshfs
#apt-get install cryptsetup     # ecryptfs-setup-swap

# scm
addaptrepository ppa:git-core/ppa # ubuntu git maintainers
aptget update
aptget install git git-gui gitk
aptget install subversion
aptget install mercurial

# services
aptget install apache2        # httpd
aptget install openssh-server # sshd

# java
aptget install openjdk-7-jdk
aptget install openjdk-6-jdk
aptget install default-jdk
aptget install icedtea-7-plugin
aptget install maven

# other languages
aptget install groovy
aptget install perl
aptget install python
aptget install ruby

# apps
aptget install pidgin
aptget install synaptic       # synaptic package manager
aptget install compizconfig-settings-manager # ccsm
aptget install compiz-plugins # extra compiz settings e.g. Window Rules
aptget install wireshark
aptget install nmap

# third party apps

if [ ! -f /etc/apt/sources.list.d/google-chrome.list ]
then
	wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
	echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list
	chmod a+r /etc/apt/sources.list.d/google-chrome.list
	aptget update
fi
aptget install google-chrome-stable

if [ ! -f /etc/apt/sources.list.d/virtualbox.list ]
then
	wget -q -O - http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add -
	echo "deb http://download.virtualbox.org/virtualbox/debian raring contrib" >> /etc/apt/sources.list.d/virtualbox.list
	chmod a+r /etc/apt/sources.list.d/virtualbox.list
	aptget update
fi
aptget install virtualbox

# attempt cleanup
aptget autoremove
