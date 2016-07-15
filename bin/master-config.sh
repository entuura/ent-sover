#!/bin/bash

PERLVER=5.18


if [[ `lsb_release -rs` != "14.04" ]] 
then
  echo -e "\n\nERROR --- INCORRECT OS - NOT EXPECTING THIS OPERATING SYSTEM"
  echo -e "This script only currently configured to work for Ubuntu 14.04."
  echo -e " Currently awaiting official VMWare instructions for installation"
  echo -e " on Ubuntu 16.x \n\n"
  exit;
fi
 


sudo apt-get -y install git \
htop \
wget \
iptraf \
dialog \
toilet 

# Install NTP client (should read NTP from OpenWRT)
sudo apt-get -y install ntp


#set Entuura Sovereignty Master hostname
sudo hostname master.soverdomain.local


#install puppet-server
#PUPPKG="puppetlabs-release-pc1"
#if [ "dpkg-query -W $PUPPKG | awk {'print $1'} = """ ]; then
#    echo -e "$PUPPKG is already installed and configured"
#else
#    cd /tmp
#    wget https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
#    sudo dpkg -i puppetlabs-release-pc1-xenial.deb
#    sudo apt-get -y update
#    rm -f /tmp/puppetlabs*
#    sudo apt-get -y upgrade puppetmaster-passenger
#fi

#Do some cleanup just in case
sudo apt-get -y autoremove

#VMWare CLI Tools

sudo apt-get install -y libwww-perl liburi-perl perl-doc
sudo apt-get install -y lib32z1 lib32ncurses5 gcc-multilib \
build-essential gcc uuid uuid-dev perl libssl-dev perl-doc \
liburi-perl libxml-libxml-perl libcrypt-ssleay-perl

## This line needed for Ubuntu 64-bit.  Needed beyond Ubuntu 14 (15 & 16)
#sudo apt-get install -y libbz2-1.0:i386
sudo apt-get install -y lib32bz2-1.0

## VMWare CLI usually installs SOAP::Lite but this takes a LONG time.  So opting to try
## using the default Ubuntu version
sudo apt-get install -y libsoap-lite-perl

#sudo apt-get install -y libnet-inet6glue-perl  libsocket6-perl
#sudo apt-get install -y libdevel-stacktrace-perl
 
cd /tmp
DATA=""
RETRY=10
VMFILEDIR="vmware-vsphere-cli-distrib"
VMFILETAR="VMware-vSphere-CLI-6.0.0-3561779.x86_64.tar"
VMFILE="$VMFILETAR.gz"
rm -rf /tmp/$VMFILE /tmp/$VMFILEDIR /tmp/$VMFILETAR
VMURL="http://downloads.entuura.org/ent-sover/vmware/$VMFILE"
while [ 1 ]; do
   wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 0 --continue $VMURL
   if [ $? = 0 ]; then break; fi; # check return value, break if successful (0)
   sleep 1s;
done;
gunzip $VMFILE
tar xf $VMFILETAR

if [ -d "/tmp/$VMFILEDIR" -a ! -h "/tmp/$VMFILEDIR" ]
then
  echo -e "Now Running Installer"
  cd /tmp/$VMFILEDIR
  sudo ./vmware-install.pl
else
  echo "Error: $VMFILEDIR not found or is symlink to $(readlink -f ${VMFILEDIR})."
fi


# PATCH the VMWare vSPHERE CLI Tool to fix error message about flow control operator in VMCommon.pm
cd /tmp
VMURL="http://downloads.entuura.org/ent-sover/vmware/patches/VICommon.pm.patch"
while [ 1 ]; do
   wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 0 --continue $VMURL
   if [ $? = 0 ]; then break; fi; # check return value, break if successful (0)
   sleep 1s;
done;

cd /usr/share/perl/$PERLVER/VMware
sudo patch ./VICommon.pm /tmp/VICommon.pm.patch 
rm -rf /tmp/VICommon.pm.patch



