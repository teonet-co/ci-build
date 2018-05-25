# Teonet CI-Ubuntu Dockerfile
# gitlab.ksproject.org:5000/ci/ubuntu_teonet

FROM ubuntu:16.04
MAINTAINER Kirill Scherba <kirill@scherba.ru>

RUN \
apt-get update  && \ 
apt-get -y upgrade && \
apt-get -y install autoconf intltool libtool libglib2.0-dev doxygen make gcc g++ git
 
# docker build --no-cache -t ubuntu_teonet -f ci-ubuntu/Dockerfile .
# docker tag ubuntu_teonet gitlab.ksproject.org:5000/ci/ubuntu_teonet
