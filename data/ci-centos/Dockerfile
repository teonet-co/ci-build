# Teonet CI-Centos Dockerfile
# gitlab.ksproject.org:5000/ci/centos_teonet

FROM centos:7
MAINTAINER Kirill Scherba <kirill@scherba.ru>

RUN \
yum -y update && \
\
yum install -y autoconf intltool libtool glib2-devel doxygen make gcc gcc-c++ git
 
# docker build --no-cache -t centos_teonet -f ci-centos/Dockerfile .
# docker tag centos_teonet gitlab.ksproject.org:5000/ci/centos_teonet
