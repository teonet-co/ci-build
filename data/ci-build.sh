#!/bin/sh
# 
# File:   ci-build.sh
# Author: Kirill Scherba <kirill@scherba.ru>
#
# Created on May 26, 2018, 11:38:53 AM
#

# This script create and publish docker images which used in Teonet CI to build 
# Teonet applications

echo "Build and publich ci-build images, (c) Kirill Scherba 2018"

# Build CI ubuntu_teonet
docker build --no-cache -t ubuntu_teonet -f ci-ubuntu/Dockerfile .
docker tag ubuntu_teonet gitlab.ksproject.org:5000/ci/ubuntu_teonet
docker push gitlab.ksproject.org:5000/ci/ubuntu_teonet

# Build CI centos_teonet
docker build --no-cache -t centos_teonet -f ci-centos/Dockerfile .
docker tag centos_teonet gitlab.ksproject.org:5000/ci/centos_teonet
docker push centos_teonet gitlab.ksproject.org:5000/ci/centos_teonet
