#!/usr/bin/env bash

# Automatically build emacs
# OS: ubuntu 20.04, 22.04
# Version: emacs-29.1

# utilities
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
DEFAULT="\033[0m"

function info () { echo -e "${GREEN}$*${DEFAULT}"; }
function warn () { echo -e "${YELLOW}$*${DEFAULT}"; }
function error () { echo -e "${RED}$*${DEFAULT}"; }

# main
readonly version="29.1"
readonly server="https://mirrors.ustc.edu.cn"

# download source tarball
if [[ ! -d emacs-"${version}" ]]; then
	wget ${server}/gnu/emacs/emacs-"${version}".tar.gz
	tar xzvf emacs-"${version}".tar.gz
fi

# Install dependencies
gcc_major_version=$(gcc --version | head -n1 | awk '{ print $NF }' | cut -d. -f1)
sudo apt-get -y install \
	build-essential \
	mailutils \
	libgccjit-"${gcc_major_version}"-dev
sudo apt-get build-dep emacs || { error "Failed to build-dep emacs"; exit 1; }

## Enhance X11 UI, https://superuser.com/questions/1128721/compiling-emacs-25-1-on-ubuntu-16-04/1129052#1129052
## However, it doesn't show any differences by the comparison of building w/ and w/o enhancement
## Uncomment next two lines to use X11 enhancement
# sudo apt install -y libgtk-3-dev libwebkit2gtk-4.0-dev
# enhance_option="--with-cairo --with-xwidgets --with-x-toolkit=gtk3"

# build source
cd emacs-"${version}" && mkdir -p build && cd build
../configure --with-native-compilation --with-mailutils || { error "configure failed"; exit 1; }
make -j$(nproc)

# install binary
sudo make -j$(nproc) install # prefix=/path/to

# clean
make clean
make distclean
cd ../..
rm -r emacs-"${version}"
rm emacs-"${version}".tar.gz
