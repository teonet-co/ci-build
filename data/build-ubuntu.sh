#!/bin/sh

# Set project dependence to make Teonet project from sources at empty host

# Upgrade Ubuntu
sudo apt-get update
sudo apt-get -y upgrade

# Autoconf dependence
sudo apt-get -y install autoconf intltool libtool libglib2.0-dev doxygen make gcc g++

# Project dependence
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8CC88F3BE7D6113C
sudo apt-get install -y software-properties-common
sudo add-apt-repository "deb http://repo.ksproject.org/ubuntu/ teonet main"
sudo apt-get update
#
sudo apt-get install -y libteonet-dev

# Build embedded components
cd embedded/libwebsite && ./waf configure --prefix=/usr && ./waf build && cd ../..
cd embedded/jsmn && make && cd ../..

# Update system dynamic libraries configuration
sudo ldconfig
