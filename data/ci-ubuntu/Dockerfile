# Teonet CI-Ubuntu Dockerfile
# gitlab.ksproject.org:5000/ci/ubuntu_teonet

FROM ubuntu:16.04
MAINTAINER Kirill Scherba <kirill@scherba.ru>

RUN \
apt-get update  && \
apt-get -y upgrade && \
apt-get -y install autoconf intltool libtool libglib2.0-dev doxygen make gcc g++ \
    git sudo \
    cpputest libconfuse-common libconfuse-dev libconfuse0 libcpputest-dev \
    libcunit1 libcunit1-dev libcurl3 libcurl4-openssl-dev libev-dev libev4 \
    libssl-dev libssl-doc uuid-dev \
    cmake cmake-data libarchive13 libjsoncpp1 liblzo2-2 unzip \
    lftp jq

# docker build --no-cache -t ubuntu_teonet -f ci-ubuntu/Dockerfile .
# docker tag ubuntu_teonet gitlab.ksproject.org:5000/ci/ubuntu_teonet
