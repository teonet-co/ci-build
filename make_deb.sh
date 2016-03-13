#!/bin/sh
# Create DEBIAN package

# Parameters:
#
# @param $1 Version
# @param $2 Library Major version
# @param $3 Library version
# @param $4 Release
# @param $5 Architecture
# @param $6 RPM subtype = "deb" (not used, reserved)
# @param $7 PACKET_NAME
# @param $8 PACKET_DESCRIPTION
# @param $9 MAINTAINER
# @param $10 DEPENDS

# Include make deb functions
PWD=`pwd`
. "$PWD/ci-build/make_deb_inc.sh"

# Set exit at error
set -e

# Check parameters and set defaults
check_param $1 $2 $3 $4 $5 $6 $7 $8 $9 $10
# Set global variables:
# VER_ONLY=$1
# LIBRARY_HI_VERSION=$2
# LIBRARY_VERSION=$3
# RELEASE=$4
# ARCH=$5
# VER=$1-$RELEASE
# PACKET_NAME=$7
# PACKET_DESCRIPTION=$8
# MAINTAINER=$9
# DEPENDS=$10

# Set Variables
#DEPENDS="libteonet-dev"
    # Note: Add this to Depends if test will be added to distributive:
    # libcunit1-dev (>= 2.1-2.dfsg-1)
#MAINTAINER="kirill@scherba.ru"
VER_ARCH=$VER"_"$ARCH
PACKAGE_NAME=$PACKET_NAME"_"$VER_ARCH
REPO_JUST_CREATED=0
REPO=../repo

# Main message
echo $ANSI_BROWN"Create debian packet $PACKET_NAME""_$VER_ARCH.deb"$ANSI_NONE
echo ""

# Update and upgrade build host
update_host

# Create deb repository -------------------------------------------------------

# Install reprepro
echo $ANSI_BROWN"Install reprepro:"$ANSI_NONE
echo ""
sudo apt-get install -y reprepro
echo ""

# Create DEB repository
create_deb_repo $REPO ubuntu Teonet teonet ci-build/gpg_key

# Add dependences to the repository
#if [ $REPO_JUST_CREATED = 1 ]; then

    # Make and add libtuntap
    # ci-build/make_libtuntap.sh

#fi

# Create deb package ----------------------------------------------------------

# Configure and make auto configure project (in current folder)
make_counfigure

# Make install
make_install $PWD/$PACKAGE_NAME

# Create DEBIAN control file
create_deb_control $PACKAGE_NAME $PACKET_NAME $VER $ARCH "${DEPENDS}" "${MAINTAINER}" "${PACKET_DESCRIPTION}"

# Build package
build_deb_package $PACKAGE_NAME

## Install and run application to check created package
#install_run_deb $PACKAGE_NAME "teovpn -?"
#
## Show version of installed depends
#show_teonet_depends
#
## Remove package
#apt_remove $PACKET_NAME

# Add packet to repository ----------------------------------------------------

# Add DEB packages to local repository
add_deb_package $REPO/ubuntu teonet $PACKAGE_NAME

# Upload repository to remote host, test install and run application ----------
if [ ! -z "$CI_BUILD_REF" ]; then

    # Upload repository to remote host by ftp:
    ci-build/make_remote_upload.sh

    # Install packet from remote repository
    ci-build/make_remote_install.sh

    # Make and upload documentation
    ci-build/make_remote_doc_upload.sh $PACKET_NAME

fi
