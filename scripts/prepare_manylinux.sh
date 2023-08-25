#!/usr/bin/env bash

set -eux

FREETYPE_VERSION=${FREETYPE_VERSION:-"VER-2-13-0"}
FONTCONFIG_VERSION=${FONTCONFIG_VERSION:-"2.14.0"}

install_freetype() {
    git clone https://gitlab.freedesktop.org/freetype/freetype.git \
        -b $FREETYPE_VERSION --depth 1
    cd freetype
    ./autogen.sh
    ./configure --sysconfdir=/etc --prefix=/usr --mandir=/usr/share/man
    make
    make -j
    make install
    cd ..
}

install_fontconfig() {
    git clone https://gitlab.freedesktop.org/fontconfig/fontconfig.git \
        -b $FONTCONFIG_VERSION --depth 1
    cd fontconfig
    ./autogen.sh --sysconfdir=/etc --prefix=/usr --mandir=/usr/share/man
    make -j
    make install
    cd ..
}

yum --disablerepo=epel install -y gperf gettext-devel libuuid-devel
install_freetype
install_fontconfig
