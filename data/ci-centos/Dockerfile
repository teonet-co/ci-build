# Teonet CI-Centos Dockerfile
# gitlab.ksproject.org:5000/ci/centos_teonet

FROM centos:7
MAINTAINER Kirill Scherba <kirill@scherba.ru>

RUN \
yum -y update && \
yum install -y epel-release && \
yum -y update && \
\
yum install -y autoconf intltool libtool glib2-devel doxygen make gcc gcc-c++ git \
\
openssl-devel libev-devel libuuid-devel libcurl-devel \
\
libcurl-devel libev-devel libuuid-devel openssl-devel \
bzip2 wget cmake unzip && \ 
\
git clone https://github.com/cpputest/cpputest.git && \
cd cpputest && \
autoreconf . -i && \
./configure && \
make && \
make install

# docker build --no-cache -t centos_teonet -f ci-centos/Dockerfile .
# docker tag centos_teonet gitlab.ksproject.org:5000/ci/centos_teonet
