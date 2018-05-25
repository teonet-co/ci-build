# Teonet CI-Opensuse Dockerfile
# gitlab.ksproject.org:5000/ci/opensuse_teonet

FROM opensuse:42.3
MAINTAINER Kirill Scherba <kirill@scherba.ru>

RUN \
zypper update && \
sudo zypper --non-interactive install -y autoconf intltool libtool glib2-devel doxygen make gcc g++ git
 
# docker build --no-cache -t opensuse_teonet -f ci-opensuse/Dockerfile .
# docker tag opensuse_teonet gitlab.ksproject.org:5000/ci/opensuse_teonet
