#!/bin/bash
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
# @param $11 LICENSES
# @param $12 VCS_URL

# Include make deb functions
PWD=`pwd`
. "$PWD/ci-build/make_deb_inc.sh"

# Set exit at error
set -e

# Check parameters and set defaults
echo "check_param: " $1 $2 $3 $4 $5 $6 $7 "$8" "$9" "${10}" "${11}" "${12}"
check_param $1 $2 $3 $4 $5 $6 $7 "$8" "$9" "${10}" "${11}" "${12}"
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
# DEPENDS="libteonet-dev"
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

# Download existing repository to local host -----------------------------------
if [ ! -z "$CI_BUILD_REF" ]; then
    
    # Download repository from remote host by ftp:
    ci-build/make_remote_download.sh
    
fi

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

# Upload DEB packages to Bintray  ---------------------------------------------
if [ ! -z "$CI_BUILD_REF_BT" ]; then
    
    # JQ uses to check JSON
    sudo apt-get install -y jq
    echo ""
    
    # Create packet if not exists
    if [ $(curl -X GET -u$CI_BINTRAY_USER:$CI_BINTRAY_API_KEY "https://api.bintray.com/packages/teonet-co/u/"$PACKET_NAME | jq -r ".name") != $PACKET_NAME ]; then
        echo $ANSI_BROWN"Create package "$PACKET_NAME" in Bintray repository:"$ANSI_NONE
        echo ""
        D='{"name":"'$PACKET_NAME'","licenses":'$LICENSES',"vcs_url":"'$VCS_URL'","desc":"'$PACKET_DESCRIPTION'"}'
        echo $D
        #curl -vvf -X POST -u$CI_BINTRAY_USER:$CI_BINTRAY_API_KEY -H "Content-Type:application/json" https://api.bintray.com/packages/teonet-co/u --data '{"name":"'$PACKET_NAME'","licenses": ["MIT"],"vcs_url": "https://github.com/teonet-co/teoccl.git"}'
        curl -vvf -X POST -u$CI_BINTRAY_USER:$CI_BINTRAY_API_KEY -H "Content-Type:application/json" https://api.bintray.com/packages/teonet-co/u --data '{"name":"'$PACKET_NAME'","licenses":'$LICENSES',"vcs_url": "'$VCS_URL'"}'
        #"licenses":'$LICENSES',
        #,"vcs_url":"'$VCS_URL'","desc":"'$PACKET_DESCRIPTION'"
        #
        # {"name":"libteoccl","repo":"u","owner":"teonet-co","desc":null,"labels":[],"attribute_names":[],"licenses":["LGPL-3.0","MIT"],"custom_licenses":[],"followers_count":0,"created":"2019-03-06T18:07:56.664Z","website_url":null,"issue_tracker_url":null,"github_repo":"","github_release_notes_file":"","public_download_numbers":false,"public_stats":true,"linked_to_repos":[],"versions":[],"latest_version":null,"updated":"2019-03-06T18:07:56.710Z","rating_count":0,"system_ids":[],"vcs_url":"https://github.com/teonet-co/teoccl.git","maturity":""}
        echo ""
    fi;
    echo ""
    
    echo $ANSI_BROWN"Upload DEB packages to Bintray repository:"$ANSI_NONE
    echo ""
    # Distribution wheezy
    # Upload file
    curl -X PUT -T $PACKAGE_NAME.deb -u$CI_BINTRAY_USER:$CI_BINTRAY_API_KEY "https://api.bintray.com/content/teonet-co/u/pool/main/"$PACKET_NAME"/"$PACKAGE_NAME"_wheezy.deb;deb_distribution=wheezy;deb_component=main;deb_architecture="$VER_ARCH";override=1;publish=1;bt_package="$PACKET_NAME";bt_version="$VER
    echo ""
    # Distribution bionic
    # Upload file
    curl -X PUT -T $PACKAGE_NAME.deb -u$CI_BINTRAY_USER:$CI_BINTRAY_API_KEY "https://api.bintray.com/content/teonet-co/u/pool/main/"$PACKET_NAME"/"$PACKAGE_NAME"_bionic.deb;deb_distribution=bionic;deb_component=main;deb_architecture="$VER_ARCH";override=1;publish=1;bt_package="$PACKET_NAME";bt_version="$VER
    echo ""
    
    #curl -H 'Content-Type: application/json' -X PUT -d "{ \"list_in_downloads\":true }" -u${USER}:${API} https://api.bintray.com/file_metadata/lordofhyphens/Slic3r/$(basename $1)
    
    # Add to direct download list
    #curl -vvf -X PUT -u$CI_BINTRAY_USER:$CI_BINTRAY_API_KEY -H "Content-Type: application/json" -d '{"list_in_downloads":true}' "https://api.bintray.com/file_metadata/teonet-co/u/pool/main/"$PACKET_NAME"/"$PACKAGE_NAME"_wheezy.deb"
    #echo ""
    
    # Add to direct download list
    #curl -vvf -X PUT -u$CI_BINTRAY_USER:$CI_BINTRAY_API_KEY -H "Content-Type: application/json" -d '{"list_in_downloads":true}' "https://api.bintray.com/file_metadata/teonet-co/u/pool/main/"$PACKET_NAME"/"$PACKAGE_NAME"_bionic.deb"
    #echo ""
fi
